FROM docker.io/crowdsecurity/spoa-bouncer:v0.3.0 AS crowdsec-assets

FROM docker.io/library/haproxy:3.3-alpine

COPY --from=crowdsec-assets /usr/lib/crowdsec-haproxy-spoa-bouncer /usr/lib/crowdsec-haproxy-spoa-bouncer
COPY --from=crowdsec-assets /var/lib/crowdsec-haproxy-spoa-bouncer /var/lib/crowdsec-haproxy-spoa-bouncer
