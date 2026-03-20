#!/bin/sh
set -eu

NGINX_UID='300001'
KANIDM_UID='300002'
STALWART_UID='300006'

if [ -z "${RENEWED_LINEAGE:-}" ]; then
    echo "RENEWED_LINEAGE is not set" >&2
    exit 1
fi

domain="$(basename "${RENEWED_LINEAGE}")"
archive_dir="/etc/letsencrypt/archive/${domain}"
live_dir="/etc/letsencrypt/live/${domain}"

if [ ! -d "${archive_dir}" ] || [ ! -d "${live_dir}" ]; then
    echo "Missing certbot lineage directories for ${domain}" >&2
    exit 1
fi

chmod 0711 /etc/letsencrypt /etc/letsencrypt/live /etc/letsencrypt/archive
chmod 0710 "${archive_dir}" "${live_dir}"

setfacl -m "u:${NGINX_UID}:x" /etc/letsencrypt /etc/letsencrypt/live /etc/letsencrypt/archive
setfacl -m "u:${KANIDM_UID}:x" /etc/letsencrypt /etc/letsencrypt/live /etc/letsencrypt/archive
setfacl -m "u:${STALWART_UID}:x" /etc/letsencrypt /etc/letsencrypt/live /etc/letsencrypt/archive

find "${archive_dir}" -maxdepth 1 -type f -name 'privkey*.pem' -exec chmod 0400 '{}' +
find "${archive_dir}" -maxdepth 1 -type f ! -name 'privkey*.pem' -exec chmod 0440 '{}' +

setfacl -m "u:${NGINX_UID}:x" "${archive_dir}" "${live_dir}"
find "${archive_dir}" -maxdepth 1 -type f -exec setfacl -m "u:${NGINX_UID}:r" '{}' +

if [ "${domain}" = 'idm.napiany.com' ]; then
    setfacl -m "u:${KANIDM_UID}:x" "${archive_dir}" "${live_dir}"
    find "${archive_dir}" -maxdepth 1 -type f -exec setfacl -m "u:${KANIDM_UID}:r" '{}' +
fi

if [ "${domain}" = 'mail.napiany.com' ]; then
    setfacl -m "u:${STALWART_UID}:x" "${archive_dir}" "${live_dir}"
    find "${archive_dir}" -maxdepth 1 -type f -exec setfacl -m "u:${STALWART_UID}:r" '{}' +
fi
