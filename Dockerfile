# Builder
FROM rust:latest AS builder

RUN apt-get update && apt-get install

WORKDIR /app

COPY . .

RUN cargo build --release

# Final
FROM debian:buster-slim

WORKDIR /app

COPY --from=builder /app/target/release/btc_rpc_proxy /app/btc_rpc_proxy

COPY btc_rpc_proxy.toml /app/btc_rpc_proxy.toml

RUN chmod 600 /app/btc_rpc_proxy.toml
RUN chmod +x /app/btc_rpc_proxy

CMD [ "/app/btc_rpc_proxy", "--conf", "btc_rpc_proxy.toml" ]