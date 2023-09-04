FROM --platform=$BUILDPLATFORM rust:latest AS builder

RUN dpkg --add-architecture arm64
RUN apt update && apt install -y musl-tools musl-dev aarch64-linux-musl-gcc musl:arm64
RUN update-ca-certificates

ARG TARGETPLATFORM
RUN case "$TARGETPLATFORM" in \
      "linux/amd64") echo x86_64-unknown-linux-musl > /rust_target.txt ;; \
      "linux/arm64") echo aarch64-unknown-linux-musl > /rust_target.txt ;; \
      *) exit 1 ;; \
    esac
RUN rustup target add $(cat /rust_target.txt)
RUN rustup toolchain install stable-$(cat /rust_target.txt) --force-non-host

WORKDIR /app
COPY . /app

RUN cargo build --release --target $(cat /rust_target.txt)
RUN cp target/$(cat /rust_target.txt)/release/btc_rpc_proxy .

FROM alpine:latest

RUN apk add --update --no-cache \
      yq \
      tini \
      bash \
      curl \
      ca-certificates \
    && rm -rf /var/cache/* \
    && mkdir /var/cache/apk

COPY --from=builder /app/btc_rpc_proxy.toml /etc/btc_rpc_proxy.toml
COPY --from=builder /app/btc_rpc_proxy /usr/local/bin/btc-rpc-proxy

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
CMD ["/usr/local/bin/btc-rpc-proxy", "--conf", "/etc/btc_rpc_proxy.toml"]
