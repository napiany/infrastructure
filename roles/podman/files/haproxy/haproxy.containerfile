FROM docker.io/crowdsecurity/spoa-bouncer:v0.3.0@sha256:6bdc237067936978d45b3ead90cf211255dad1f3156366aa39703a54a6d2db5d AS crowdsec-assets

FROM docker.io/library/haproxy:3.3-alpine@sha256:895c05c2de4bb99b7ed8553abdd27707fb56bf85cec1bfae35142c42836bf3f1

COPY --from=crowdsec-assets /usr/lib/crowdsec-haproxy-spoa-bouncer /usr/lib/crowdsec-haproxy-spoa-bouncer
COPY --from=crowdsec-assets /var/lib/crowdsec-haproxy-spoa-bouncer /var/lib/crowdsec-haproxy-spoa-bouncer
