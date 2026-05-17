use axum::{
    Router,
    routing::{get, post},
    extract::{Path, State},
    response::Response,
    body::Body,
    http::{HeaderMap, Method},
};

use reqwest::Client;
use tokio::net::TcpListener;
use futures::StreamExt;
use std::sync::Arc;
use std::time::Duration;

#[derive(Clone)]
struct AppState {
    client: Client
}

#[tokio::main]
async fn main() {

    let client = Client::builder()
        .proxy(reqwest::Proxy::all("socks5h://127.0.0.1:1080").unwrap())
        .pool_idle_timeout(Duration::from_secs(90))
        .pool_max_idle_per_host(50)
        .tcp_keepalive(Duration::from_secs(60))
        .connect_timeout(Duration::from_secs(20))
        .http2_prior_knowledge()
        .build()
        .unwrap();

    let state = Arc::new(AppState { client });

    let app = Router::new()
        .route("/*url", get(proxy).post(proxy))
        .with_state(state);

    let listener = TcpListener::bind("0.0.0.0:8080").await.unwrap();

    println!("Ultra Fast Rust Proxy running on 0.0.0.0:8080");

    axum::serve(listener, app).await.unwrap();
}

async fn proxy(
    State(state): State<Arc<AppState>>,
    Path(url): Path<String>,
    method: Method,
    headers: HeaderMap,
    body: Body
) -> Response {

    let target = url;

    let mut req = state.client.request(method, &target);

    // forward headers
    for (name, value) in headers.iter() {

        if name == "host"
        || name == "connection"
        || name == "content-length"
        {
            continue;
        }

        req = req.header(name, value);
    }

    // spoof headers اگر نبود
    if !headers.contains_key("user-agent") {
        req = req.header(
            "user-agent",
            "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 Chrome/120 Safari/537.36"
        );
    }

    if !headers.contains_key("accept") {
        req = req.header("*/*");
    }

    // forward body (برای POST)
    let body_bytes = match axum::body::to_bytes(body, usize::MAX).await {
        Ok(b) => b,
        Err(_) => Default::default()
    };

    req = req.body(body_bytes);

    let resp = match req.send().await {
        Ok(r) => r,
        Err(e) => {
            return Response::builder()
                .status(500)
                .body(Body::from(format!("proxy error {}", e)))
                .unwrap();
        }
    };

    let status = resp.status();

    let mut builder = Response::builder().status(status);

    // forward response headers
    for (name, value) in resp.headers() {

        if name == "transfer-encoding"
        || name == "connection"
        {
            continue;
        }

        builder = builder.header(name, value);
    }

    // streaming body
    let stream = resp.bytes_stream().map(|item| {
        item.map_err(|_| std::io::Error::new(
            std::io::ErrorKind::Other,
            "stream error"
        ))
    });

    let body = Body::from_stream(stream);

    builder.body(body).unwrap()
}