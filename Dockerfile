# Builder
FROM rust:1.92 AS builder

RUN apt-get update && apt-get install

WORKDIR /app

COPY . .

RUN cargo build --release

# Final
FROM debian:bookworm-slim

COPY --from=builder /app/target/release/btc_rpc_proxy /usr/bin/btc_rpc_proxy

RUN chmod +x /usr/bin/btc_rpc_proxy

SHELL [ "/bin/bash", "-c" ]
ENTRYPOINT chmod 600 /etc/btc_rpc_proxy/btc_rpc_proxy.toml && exec /usr/bin/btc_rpc_proxy --conf /etc/btc_rpc_proxy/btc_rpc_proxy.toml