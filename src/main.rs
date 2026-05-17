use axum::{
    Router,
    routing::get,
    extract::{Query, State},
    response::Response,
    body::Body,
    http::{HeaderMap, HeaderName, HeaderValue},
};

use reqwest::Client;
use std::collections::HashMap;
use tokio::net::TcpListener;
use futures::StreamExt;
use std::sync::Arc;

#[derive(Clone)]
struct AppState {
    client: Client
}

#[tokio::main]
async fn main() {

    let client = Client::builder()
        .proxy(reqwest::Proxy::all("socks5h://127.0.0.1:1080").unwrap())
        .http2_prior_knowledge()
        .build()
        .unwrap();

    let state = AppState { client };

    let app = Router::new()
        .route("/", get(proxy))
        .with_state(Arc::new(state));

    let listener = TcpListener::bind("0.0.0.0:8080").await.unwrap();

    println!("Rust WARP proxy running on 0.0.0.0:8080");

    axum::serve(listener, app).await.unwrap();
}

async fn proxy(
    State(state): State<Arc<AppState>>,
    Query(params): Query<HashMap<String,String>>,
    headers: HeaderMap
) -> Response {

    let url = match params.get("url") {
        Some(u) => u.clone(),
        None => {
            return Response::builder()
                .status(400)
                .body(Body::from("missing url"))
                .unwrap();
        }
    };

    let mut req = state.client.get(&url);

    // pass headers from client
    for (name, value) in headers.iter() {
        if let Some(name) = name {
            req = req.header(name, value);
        }
    }

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

    // copy response headers
    for (name, value) in resp.headers() {
        if name != "transfer-encoding" {
            builder = builder.header(name, value);
        }
    }

    let stream = resp.bytes_stream().map(|item| {
        item.map_err(|_| std::io::Error::new(
            std::io::ErrorKind::Other,
            "stream error"
        ))
    });

    let body = Body::from_stream(stream);

    builder.body(body).unwrap()
}