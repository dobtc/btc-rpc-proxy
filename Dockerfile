FROM rust:latest AS builder

WORKDIR /app
COPY . /app

RUN cargo build --release

FROM debian:trixie-slim

ARG DEBCONF_NOWARNINGS="yes"
ARG DEBIAN_FRONTEND noninteractive

RUN apt-get update && apt-get -y upgrade && \
    apt-get --no-install-recommends -y install \
   	tini \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
    
COPY --from=builder /app/btc_rpc_proxy.toml /etc/btc_rpc_proxy.toml
COPY --from=builder /app/target/release/btc_rpc_proxy /usr/local/bin/btc-rpc-proxy

RUN chmod 600 /etc/btc_rpc_proxy.toml
RUN chmod a+x /usr/local/bin/btc-rpc-proxy

# Container version
ARG DATE_ARG=""
ARG BUILD_ARG=0
ARG VERSION_ARG="0.3.2.7"
ENV VERSION=$VERSION_ARG

LABEL org.opencontainers.image.licenses="MIT"
LABEL org.opencontainers.image.title="Bitcoin RPC Proxy"
LABEL org.opencontainers.image.created=${DATE_ARG}
LABEL org.opencontainers.image.revision=${BUILD_ARG}
LABEL org.opencontainers.image.version=${VERSION_ARG}
LABEL org.opencontainers.image.url="https://hub.docker.com/r/dobtc/btc-rpc-proxy/"
LABEL org.opencontainers.image.source="https://github.com/dobtc/btc-rpc-proxy/"
LABEL org.opencontainers.image.description="Finer-grained permission management for bitcoind"

EXPOSE 8331

ENTRYPOINT [ "tini", "--"]
CMD ["/usr/local/bin/btc-rpc-proxy", "--conf", "/etc/btc_rpc_proxy.toml"]
