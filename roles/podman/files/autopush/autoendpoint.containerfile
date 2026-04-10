FROM docker.io/library/rust:1.94.0-alpine3.23@sha256:ff0adc35894eb79586ce752a1b5a9eadc88b938c56d8f2b4b537b6258ff3fa10 AS builder

ARG AUTOPUSH_COMMIT=7979ff16ebebf05aae6e9e200a3f44a4064c558c

RUN apk -U upgrade \
    && apk add build-base ca-certificates clang cmake curl openssl-dev openssl-libs-static pkgconf \
    && rm -rf /var/cache/apk/*

RUN curl --fail --location --silent --show-error "https://codeload.github.com/mozilla-services/autopush-rs/tar.gz/${AUTOPUSH_COMMIT}" --output /tmp/autopush-rs.tar.gz \
    && mkdir -p /src \
    && tar --extract --file /tmp/autopush-rs.tar.gz --gzip --directory /src \
    && mv /src/autopush-rs-* /app

WORKDIR /app

RUN cargo install --path autoendpoint --locked --root /app/out --no-default-features --features=redis

FROM docker.io/library/alpine:3.23@sha256:25109184c71bdad752c8312a8623239686a9a2071e8825f20acb8f2198c3f659

RUN apk -U upgrade \
    && apk add ca-certificates libgcc libstdc++ openssl \
    && rm -rf /var/cache/apk/*

RUN --network=none \
    addgroup -S -g 300002 autopush \
    && adduser -S -D -H -u 300002 -G autopush autopush

COPY --from=builder /app/out/bin/autoendpoint /usr/local/bin/autoendpoint

USER autopush

ENTRYPOINT ["/usr/local/bin/autoendpoint"]
