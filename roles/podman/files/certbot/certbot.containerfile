FROM python:3.14-alpine@sha256:cafd99109feb04f25a66a37cd71a2b5b54563b2ab25fb15632b8394e910be283

RUN apk add --no-cache acl \
    && python3 -m pip install --no-cache-dir certbot==5.5.0 certbot-dns-desec==1.3.2

ENTRYPOINT ["certbot"]
