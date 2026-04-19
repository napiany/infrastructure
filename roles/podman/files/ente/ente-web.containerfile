FROM ghcr.io/ente-io/web:04b7b48e3b92b159ceb32b2e899f65f3aac00d1c@sha256:80f1b2e6b60c1f48d5d24ae7a11738465486bf3f7345bfdaa972dc3f3152aa78

USER root

RUN if command -v addgroup >/dev/null 2>&1; then       addgroup -S -g 300022 enteweb &&       adduser -S -D -H -u 300022 -G enteweb enteweb;     else       groupadd -g 300022 enteweb &&       useradd -r -M -u 300022 -g 300022 -s /usr/sbin/nologin enteweb;     fi &&     install -d -o 300022 -g 300022 /var/cache/nginx /var/lib/nginx /run /tmp &&     chown -R 300022:300022 /etc/nginx/conf.d /out
RUN for port in 3000 3001 3002 3003 3004 3005 3006 3007 3008; do       sed -i "/listen ${port};/a\\    listen [::]:${port};" /etc/nginx/conf.d/default.conf;     done &&     chown -R 300022:300022 /etc/nginx/conf.d

USER 300022:300022
