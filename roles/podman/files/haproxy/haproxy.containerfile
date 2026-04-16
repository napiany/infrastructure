FROM docker.io/crowdsecurity/spoa-bouncer:v0.3.0@sha256:9bdf80df34f7eb8d7150836d4ad6d247cd96bd51e2a979f1c7a1b61e2c1a475f AS crowdsec-assets

FROM docker.io/library/haproxy:3.3.6-alpine@sha256:4f97a2cb7f02fd08402259e74a65ef12fcfa3dff1ef78fddecb5228a17b7f4ad

COPY --from=crowdsec-assets /usr/lib/crowdsec-haproxy-spoa-bouncer /usr/lib/crowdsec-haproxy-spoa-bouncer
COPY --from=crowdsec-assets /var/lib/crowdsec-haproxy-spoa-bouncer /var/lib/crowdsec-haproxy-spoa-bouncer
