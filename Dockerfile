FROM debian:sid-slim as builder
RUN dpkg --print-architecture > /tmp/debarch && \
    cat /tmp/debarch | sed 's/arm64/aarch64/g' > /tmp/altarch

ARG S6_VERSION="2.0.0.1"

RUN apt-get update && \
    apt-get install -yy curl && \
    mkdir -p /dist && \
    curl -sL "https://github.com/just-containers/s6-overlay/releases/download/v${S6_VERSION}/s6-overlay-$(cat /tmp/altarch).tar.gz" | tar xz -C /dist

COPY rootfs/ /dist/

FROM debian:sid-slim

RUN echo 'deb http://deb.debian.org/debian buster main' >> /etc/apt/sources.list && \
    apt-get update && apt-get install -yy --no-install-recommends \
    zoneminder php-fpm fcgiwrap procps libvlc-bin vlc-plugin-access-extra vlc-plugin-base vlc-bin ffmpeg nginx && \
    rm -rf /var/lib/apt/lists/* && \
    mkdir -p /run/php /run/zm && \
    sed -i "s/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/g" /etc/php/7.4/fpm/php.ini && \
    sed -i 's/ZM_PATH_ZMS=.*/ZM_PATH_ZMS=\/cgi-bin\/nph-zms/g' /etc/zm/conf.d/01-system-paths.conf && \
    adduser www-data video && \
    mkdir -p /run/php /run/zm && \
    chown -R www-data:www-data /run/php /run/zm && \
    chmod 644 /etc/zm/zm.conf /etc/zm/conf.d/*

ENV ZM_DB_USER='root' \
    ZM_DB_PASS='zoneminder' \
    ZM_DB_HOST='mariadb.apps' \
    TZ='America/New_York' \
    ZMS_THREADS='10' \
    S6_BEHAVIOUR_IF_STAGE2_FAILS=2

COPY --from=builder /dist/ /

ENTRYPOINT [ "/init" ]
CMD []
