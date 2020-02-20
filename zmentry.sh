#!/usr/bin/env bash
set -Eeuo pipefail

echo "ZM_DB_USER=${ZM_DB_USER}" >/etc/zm/conf.d/03-db.conf
echo "ZM_DB_PASS=${ZM_DB_PASS}" >>/etc/zm/conf.d/03-db.conf
echo "ZM_DB_HOST=${ZM_DB_HOST}" >>/etc/zm/conf.d/03-db.conf

setup_db() {
    SUCCESS=0
    COUNT=0
    while [[ $COUNT -le 60 && SUCCESS -eq 0 ]]; do
        sleep 1
        echo "Waiting for database..."
        echo 'select 1' | mysql "-u${ZM_DB_USER}" "-p${ZM_DB_PASS}" "-h${ZM_DB_HOST}" &>/dev/null &&
            SUCCESS=1
        COUNT=$(($COUNT + 1))
    done

    echo 'select 1' | mysql "-u${ZM_DB_USER}" "-p${ZM_DB_PASS}" "-h${ZM_DB_HOST}" zm &>/dev/null && true

    if [ $? -eq 1 ]; then
        echo "Database doesn't exist, provisioning now..."
        mysql "-u${ZM_DB_USER}" "-p${ZM_DB_PASS}" "-h${ZM_DB_HOST}" </usr/share/zoneminder/db/zm_create.sql &>/dev/null &&
            SUCCESS=1
        echo "Done!"
    else
        echo "Database already exists, skipping provisioning..."
    fi

    if [ $SUCCESS -ne 1 ]; then
        echo "Failed to initialize database..."
        exit 1
    else
        echo "Database initialized!"
    fi
}

prep_zoneminder() {
    rm -f /run/php/* /run/zm/*
    chown -R www-data:www-data /run
    rm /usr/share/zoneminder/www/tools/mootools/*
    cp -rf /usr/share/javascript/mootools/* /usr/share/zoneminder/www/tools/mootools/
    ln -sf /usr/share/zoneminder/www/tools/mootools/mootools-core.min.js /usr/share/zoneminder/www/tools/mootools/mootools-core.js
}

start_fpm() {
    php-fpm7.3 --nodaemonize --fpm-config /etc/php/7.3/fpm/php-fpm.conf &
    while [ ! -S /run/php/php7.3-fpm.sock ]; do
        echo "Waiting for php-fpm socket..."
        sleep 1
    done
    chmod 666 /run/php/php7.3-fpm.sock
    echo "php-fpm started."
    su www-data --shell /bin/bash --command 'zmpkg.pl start'
}

start_cgi() {
    su www-data --shell /bin/bash --command 'fcgiwrap -s unix:/run/php/fcgiwrap.sock' &
    while [ ! -S /run/php/fcgiwrap.sock ]; do
        echo "Waiting for fcgiwrap socket..."
        sleep 1
    done
    chmod 666 /run/php/fcgiwrap.sock
    echo "fcgiwrap started."
}

shutdown() {
    kill %1 &>/dev/null || true
    kill %2 &>/dev/null || true
    rm -f /run/php/*.sock
    exit 0
}

trap shutdown EXIT

setup_db
prep_zoneminder
start_fpm
start_cgi

echo "Services started."

wait -n &>/dev/null

shutdown
