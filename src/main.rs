use axum::{
    Router,
    routing::get,
    extract::Query,
    response::Response,
    body::Body,
};

use reqwest::Client;
use std::collections::HashMap;
use tokio::net::TcpListener;
use futures::StreamExt;

#[tokio::main]
async fn main() {

    let app = Router::new().route("/", get(proxy));

    let listener = TcpListener::bind("0.0.0.0:8080").await.unwrap();

    println!("Rust WARP proxy running on 0.0.0.0:8080");

    axum::serve(listener, app).await.unwrap();
}

async fn proxy(
    Query(params): Query<HashMap<String,String>>
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

    let client = Client::builder()
        .proxy(reqwest::Proxy::all("socks5h://127.0.0.1:1080").unwrap())
        .build()
        .unwrap();

    let resp = match client.get(&url).send().await {
        Ok(r) => r,
        Err(e) => {
            return Response::builder()
                .status(500)
                .body(Body::from(format!("proxy error {}", e)))
                .unwrap();
        }
    };

    let status = resp.status();

    let stream = resp.bytes_stream().map(|item| {
        item.map_err(|_| std::io::Error::new(
            std::io::ErrorKind::Other,
            "stream error"
        ))
    });

    let body = Body::from_stream(stream);

    Response::builder()
        .status(status)
        .body(body)
        .unwrap()
}