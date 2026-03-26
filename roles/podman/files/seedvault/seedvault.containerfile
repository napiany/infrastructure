FROM httpd:2.4.66-alpine

RUN apk add --no-cache apr-util-dbm_gdbm \
    && addgroup -S -g 300018 seedvault \
    && adduser -S -D -H -u 300018 -G seedvault seedvault

COPY seedvault-extra.conf /usr/local/apache2/conf/extra/seedvault-extra.conf

RUN sed -i \
    -e 's/^Listen 80$/Listen 8080/' \
    -e 's/^#LoadModule dav_module modules\/mod_dav.so$/LoadModule dav_module modules\/mod_dav.so/' \
    -e 's/^#LoadModule dav_fs_module modules\/mod_dav_fs.so$/LoadModule dav_fs_module modules\/mod_dav_fs.so/' \
    -e 's#^User daemon$#User seedvault#' \
    -e 's#^Group daemon$#Group seedvault#' \
    -e 's#^DocumentRoot "/usr/local/apache2/htdocs"$#DocumentRoot "/data"#' \
    -e 's#<Directory "/usr/local/apache2/htdocs">#<Directory "/data">#' \
    -e 's#^ErrorLog "logs/error_log"$#ErrorLog /proc/self/fd/2#' \
    -e 's#^CustomLog "logs/access_log" common$#CustomLog /proc/self/fd/1 common#' \
    /usr/local/apache2/conf/httpd.conf \
    && echo 'Include conf/extra/seedvault-extra.conf' >> /usr/local/apache2/conf/httpd.conf
