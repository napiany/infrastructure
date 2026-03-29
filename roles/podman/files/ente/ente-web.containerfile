FROM ghcr.io/ente-io/web:23d6963caebcf2353a8af83d75a3848ac6502a06@sha256:c74f9b7066db161f6b6fe5af6f6cd6e19d31f8324b57a2c7fee203a3fdebc451

USER root

RUN if command -v addgroup >/dev/null 2>&1; then       addgroup -S -g 300022 enteweb &&       adduser -S -D -H -u 300022 -G enteweb enteweb;     else       groupadd -g 300022 enteweb &&       useradd -r -M -u 300022 -g 300022 -s /usr/sbin/nologin enteweb;     fi &&     install -d -o 300022 -g 300022 /var/cache/nginx /var/lib/nginx /run /tmp &&     chown -R 300022:300022 /etc/nginx/conf.d /out

USER 300022:300022
