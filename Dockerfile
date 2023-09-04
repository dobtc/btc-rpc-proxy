FROM --platform=$BUILDPLATFORM rust:latest AS builder

WORKDIR /app
COPY . /app

RUN cargo build --target x86_64-unknown-linux-musl --release
COPY /app/target/release/btc_rpc_proxy /brp-amd64
RUN cargo build --target aarch64-unknown-linux-musl --release
COPY /app/target/release/btc_rpc_proxy /brp-arm64

FROM alpine:latest

RUN apk add --update --no-cache bash curl tini yq ca-certificates

COPY --from=builder /app/btc_rpc_proxy.toml /etc/btc_rpc_proxy.toml
COPY --from=builder /brp-$TARGETARCH /usr/local/bin/btc-rpc-proxy

RUN chmod 600 /etc/btc_rpc_proxy.toml
RUN chmod a+x /usr/local/bin/btc-rpc-proxy

# Container version
ARG DATE_ARG=""
ARG BUILD_ARG=0
ARG VERSION_ARG="0.3.2.7"
ENV VERSION=$VERSION_ARG

LABEL org.opencontainers.image.created=${DATE_ARG}
LABEL org.opencontainers.image.revision=${BUILD_ARG}
LABEL org.opencontainers.image.version=${VERSION_ARG}
LABEL org.opencontainers.image.url=https://hub.docker.com/r/dobtc/btc-rpc-proxy/
LABEL org.opencontainers.image.source=https://github.com/dobtc/btc-rpc-proxy/

EXPOSE 8332

ENTRYPOINT [ "/sbin/tini", "--"]
CMD ["/usr/local/bin/btc-rpc-proxy", "--conf /etc/btc_rpc_proxy.toml"]
