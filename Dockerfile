FROM rust:latest AS builder

WORKDIR /app
COPY . /app

ARG VERSION_ARG="0.0"
RUN sed -i "s/0.0.0-development/${VERSION_ARG}.0/" /app/Cargo.toml
RUN sed -i "s/0.0.0-development/${VERSION_ARG}.0/" /app/Cargo.lock

RUN cargo build --release

FROM debian:bookworm-slim

ARG DEBCONF_NOWARNINGS="yes"
ARG DEBIAN_FRONTEND noninteractive
ARG DEBCONF_NONINTERACTIVE_SEEN true

RUN apt-get update \
    && apt-get --no-install-recommends -y install tini \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

COPY --from=builder /app/btc_rpc_proxy.toml /etc/btc_rpc_proxy.toml
COPY --from=builder /app/target/release/btc_rpc_proxy /usr/local/bin/btc-rpc-proxy

RUN chmod 600 /etc/btc_rpc_proxy.toml
RUN chmod a+x /usr/local/bin/btc-rpc-proxy

EXPOSE 8331

ENTRYPOINT [ "tini", "--"]
CMD ["/usr/local/bin/btc-rpc-proxy", "--conf", "/etc/btc_rpc_proxy.toml"]
