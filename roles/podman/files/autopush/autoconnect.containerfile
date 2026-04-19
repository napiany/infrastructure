FROM docker.io/library/rust:1.94.1-alpine3.23@sha256:77237dd363a0b127bb5ef532c2d64c0deb380b738e43a9c4bdac73398d6d0a08 AS builder

ARG AUTOPUSH_VERSION=1.81.3

RUN apk -U upgrade \
    && apk add build-base ca-certificates clang cmake curl openssl-dev openssl-libs-static pkgconf \
    && rm -rf /var/cache/apk/*

RUN curl --fail --location --silent --show-error "https://codeload.github.com/mozilla-services/autopush-rs/tar.gz/${AUTOPUSH_VERSION}" --output /tmp/autopush-rs.tar.gz \
    && mkdir -p /src \
    && tar --extract --file /tmp/autopush-rs.tar.gz --gzip --directory /src \
    && mv /src/autopush-rs-* /app

WORKDIR /app

RUN cargo install --path autoconnect --locked --root /app/out --no-default-features --features=redis

FROM docker.io/library/alpine:3.23.4@sha256:5b10f432ef3da1b8d4c7eb6c487f2f5a8f096bc91145e68878dd4a5019afde11

RUN apk -U upgrade \
    && apk add ca-certificates libgcc libstdc++ openssl \
    && rm -rf /var/cache/apk/*

RUN --network=none \
    addgroup -S -g 300001 autopush \
    && adduser -S -D -H -u 300001 -G autopush autopush

COPY --from=builder /app/out/bin/autoconnect /usr/local/bin/autoconnect

USER autopush

ENTRYPOINT ["/usr/local/bin/autoconnect"]
