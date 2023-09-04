FROM rust:latest AS builder

WORKDIR /app
COPY . /app

RUN cargo build --release

FROM alpine:latest

RUN apk update
RUN apk add bash curl tini

RUN wget -qO /usr/local/bin/yq https://github.com/mikefarah/yq/releases/latest/download/yq_linux_${TARGET_PLATFORM} && chmod +x /usr/local/bin/yq

COPY --from=builder /app/btc-rpc-proxy /usr/local/bin/btc-rpc-proxy

RUN chmod a+x /usr/local/bin/btc-rpc-proxy
ADD ./entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod a+x /usr/local/bin/entrypoint.sh
ADD ./check-rpc.sh /usr/local/bin/check-rpc.sh
RUN chmod a+x /usr/local/bin/check-rpc.sh

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
