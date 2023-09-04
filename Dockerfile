FROM rust:latest AS builder

WORKDIR /app
COPY . /app

RUN cargo build --release

FROM alpine:latest

RUN apk --update --no-cache bash curl tini yq

COPY --from=builder /app/btc_rpc_proxy.toml /etc/btc_rpc_proxy.toml
COPY --from=builder /app/target/release/btc_rpc_proxy /usr/local/bin/btc-rpc-proxy

RUN chmod a+x /usr/local/bin/btc-rpc-proxy
ADD ./entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod a+x /usr/local/bin/entrypoint.sh

# Container version
ARG DATE_ARG=""
ARG BUILD_ARG=0
ARG VERSION_ARG="0.0"
ENV VERSION=$VERSION_ARG

LABEL org.opencontainers.image.created=${DATE_ARG}
LABEL org.opencontainers.image.revision=${BUILD_ARG}
LABEL org.opencontainers.image.version=${VERSION_ARG}
LABEL org.opencontainers.image.url=https://hub.docker.com/r/dobtc/btc-rpc-proxy/
LABEL org.opencontainers.image.source=https://github.com/dobtc/btc-rpc-proxy/

EXPOSE 8332

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
