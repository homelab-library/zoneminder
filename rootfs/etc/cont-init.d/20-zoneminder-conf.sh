#!/usr/bin/with-contenv bash
set -Eeuo pipefail

TZ_PARTS=(${TZ//\// })
TZ_REGION="${TZ_PARTS[0]}"
TZ_LOCAL="${TZ_PARTS[1]}"

echo "ZM_DB_USER=${ZM_DB_USER}" >/etc/zm/conf.d/03-db.conf
echo "ZM_DB_PASS=${ZM_DB_PASS}" >>/etc/zm/conf.d/03-db.conf
echo "ZM_DB_HOST=${ZM_DB_HOST}" >>/etc/zm/conf.d/03-db.conf

rm -f /run/php/* /run/zm/*
echo "$TZ" > /etc/timezone
sed -i "s/;date.timezone.*/date.timezone=${TZ_REGION}\/${TZ_LOCAL}/g" /etc/php/7.4/fpm/php.ini
sed -i 's/pool.d\/\*.conf/pool.d\/www.conf/g' /etc/php/7.4/fpm/php-fpm.conf
ln -sf "/usr/share/zoneinfo/${TZ_REGION}/${TZ_LOCAL}" /etc/localtime

if [[ ZM_MULTISERVER -eq 1 ]]; then
    echo "ZM_SERVER_HOST=$(hostname)" > "/etc/zm/conf.d/02-multiserver.conf"
fi
