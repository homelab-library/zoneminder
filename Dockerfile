FROM debian:buster-slim

RUN apt-get update && apt-get install -yy \
    curl apt-transport-https gnupg && \
    echo 'deb https://zmrepo.zoneminder.com/debian/release-1.34 buster/' > /etc/apt/sources.list.d/10-zoneminder.list && \
    curl -sL https://zmrepo.zoneminder.com/debian/archive-keyring.gpg | apt-key add - && \
    apt-get update && apt-get install -yy --no-install-recommends \
    zoneminder php-fpm fcgiwrap procps libvlc-bin vlc-plugin-access-extra vlc-plugin-base vlc-bin && \
    rm -rf /var/lib/apt/lists/* && \
    mkdir -p /run/php /run/zm && \
    sed -i "s/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/g" /etc/php/7.3/fpm/php.ini && \
    sed -i 's/ZM_PATH_ZMS=.*/ZM_PATH_ZMS=\/cgi-bin\/nph-zms/g' /etc/zm/conf.d/01-system-paths.conf && \
    adduser www-data video

ENV ZM_DB_USER='root' \
    ZM_DB_PASS='zoneminder' \
    ZM_DB_HOST='mariadb.apps' \
    ZMS_THREADS='10'

COPY zmentry.sh /

CMD ["/zmentry.sh"]
