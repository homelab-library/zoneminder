#!/usr/bin/with-contenv bash
set -Eeuo pipefail

echo "ZM_DB_USER=${ZM_DB_USER}" >/etc/zm/conf.d/03-db.conf
echo "ZM_DB_PASS=${ZM_DB_PASS}" >>/etc/zm/conf.d/03-db.conf
echo "ZM_DB_HOST=${ZM_DB_HOST}" >>/etc/zm/conf.d/03-db.conf

rm -f /run/php/* /run/zm/*
echo "America/New_York" > /etc/timezone
sed -i "s/;date.timezone.*/date.timezone=America\/New_York/g" /etc/php/7.4/fpm/php.ini
