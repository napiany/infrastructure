FROM alpine:3.23 AS crowdsec-builder

ARG CS_NGINX_BOUNCER_VERSION=v1.1.1
ARG LUA_RESTY_HTTP_VERSION=v0.17.1

USER root

RUN apk add --no-cache \
      ca-certificates \
      curl \
      findutils \
      gzip \
      tar \
      xz

RUN curl --fail --location --silent --show-error "https://github.com/crowdsecurity/cs-nginx-bouncer/releases/download/${CS_NGINX_BOUNCER_VERSION}/crowdsec-nginx-bouncer.tgz" --output /tmp/cs-nginx-bouncer.tar.gz && \
    tar --extract --file /tmp/cs-nginx-bouncer.tar.gz --gzip --directory /tmp && \
    bouncer_dir="$(find /tmp -maxdepth 1 -type d -name 'crowdsec-nginx-bouncer-*' | head -n 1)" && \
    install -d /out/usr/local/lua/crowdsec/plugins/crowdsec && \
    install -d /out/var/lib/crowdsec/lua/templates && \
    cp -r "$bouncer_dir/lua-mod/lib/." /out/usr/local/lua/crowdsec/ && \
    cp -r "$bouncer_dir/lua-mod/templates/." /out/var/lib/crowdsec/lua/templates/ && \
    rm -rf /tmp/cs-nginx-bouncer.tar.gz "$bouncer_dir"

RUN curl --fail --location --silent --show-error "https://github.com/ledgetech/lua-resty-http/archive/refs/tags/${LUA_RESTY_HTTP_VERSION}.tar.gz" --output /tmp/lua-resty-http.tar.gz && \
    tar --extract --file /tmp/lua-resty-http.tar.gz --gzip --directory /tmp && \
    resty_dir="$(find /tmp -maxdepth 1 -type d -name 'lua-resty-http-*' | head -n 1)" && \
    install -d /out/usr/local/share/lua/5.1/resty && \
    cp -r "$resty_dir/lib/resty/." /out/usr/local/share/lua/5.1/resty/ && \
    rm -rf /tmp/lua-resty-http.tar.gz "$resty_dir"

FROM alpine:3.23

USER root

RUN apk --no-cache upgrade && \
    apk add --no-cache \
      ca-certificates \
      lua5.1-cjson \
      luajit \
      nginx \
      nginx-mod-http-lua && \
    update-ca-certificates && \
    ln -sf /etc/ssl/cert.pem /etc/ssl/ca-bundle.pem && \
    install -d -o nginx -g nginx \
      /etc/nginx/conf.d \
      /etc/nginx/snippets \
      /etc/nginx/vhosts.d \
      /srv/nginx \
      /usr/local/lua/crowdsec/plugins/crowdsec \
      /usr/local/share/lua/5.1/resty \
      /var/cache/nginx \
      /var/lib/crowdsec/lua/templates \
      /var/lib/nginx \
      /var/log/nginx && \
    rm -f /var/log/nginx/access.log /var/log/nginx/error.log && \
    install -o nginx -g nginx -m 0644 /dev/null /var/log/nginx/access.log && \
    install -o nginx -g nginx -m 0644 /dev/null /var/log/nginx/error.log

COPY --from=crowdsec-builder /out/usr/local/lua/crowdsec /usr/local/lua/crowdsec
COPY --from=crowdsec-builder /out/usr/local/share/lua /usr/local/share/lua
COPY --from=crowdsec-builder /out/var/lib/crowdsec/lua/templates /var/lib/crowdsec/lua/templates
COPY nginx.conf /etc/nginx/nginx.conf

USER nginx

CMD ["nginx", "-g", "daemon off;"]
