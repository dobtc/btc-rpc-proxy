FROM rust:latest AS builder
COPY . .
RUN cargo build --release

FROM debian:bookworm-slim
COPY --from=builder ./target/release/docker ./target/release/docker
CMD ["/target/release/docker"]
