FROM rust:1.94.0-alpine3.23 AS builder

ARG AUTOPUSH_COMMIT=8e5d850d5a99bf44c407174d2c95c3a5deea1c14

RUN apk add --no-cache build-base ca-certificates clang cmake curl openssl-dev openssl-libs-static pkgconf

RUN curl --fail --location --silent --show-error "https://codeload.github.com/mozilla-services/autopush-rs/tar.gz/${AUTOPUSH_COMMIT}" --output /tmp/autopush-rs.tar.gz && mkdir -p /src && tar --extract --file /tmp/autopush-rs.tar.gz --gzip --directory /src && mv /src/autopush-rs-* /app

WORKDIR /app

RUN cargo install --path autoendpoint --locked --root /app/out --no-default-features --features=enterprise

FROM alpine:3.23

RUN apk add --no-cache ca-certificates libgcc libstdc++ openssl

COPY --from=builder /app/out/bin/autoendpoint /usr/local/bin/autoendpoint

ENTRYPOINT ["/usr/local/bin/autoendpoint"]
