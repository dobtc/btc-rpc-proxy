# Builder
FROM rust:latest AS builder

RUN apt-get update && apt-get install

WORKDIR /app

COPY . .

RUN cargo build --release

# Final
FROM debian:bookworm-slim

WORKDIR /app

COPY --from=builder /app/target/release/btc_rpc_proxy /app/btc_rpc_proxy

RUN chmod +x /app/btc_rpc_proxy

SHELL [ "/bin/bash", "-c" ]
ENTRYPOINT chmod 600 /app/btc_rpc_proxy.toml && exec /app/btc_rpc_proxy --conf /app/btc_rpc_proxy.toml