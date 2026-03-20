FROM python:3.14-alpine

RUN apk add --no-cache acl \
    && python3 -m pip install certbot certbot-dns-desec

ENTRYPOINT ["certbot"]
