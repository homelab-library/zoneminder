#!/usr/bin/with-contenv bash
set -Eeuo pipefail

SUCCESS=2

echo 'select 1' | mysql "-u${ZM_DB_USER}" "-p${ZM_DB_PASS}" "-h${ZM_DB_HOST}" zm &>/dev/null && true

if [ $? -eq 1 ]; then
    echo "Database doesn't exist, provisioning now..."
    mysql "-u${ZM_DB_USER}" "-p${ZM_DB_PASS}" "-h${ZM_DB_HOST}" </usr/share/zoneminder/db/zm_create.sql &>/dev/null &&
        SUCCESS=0
    echo "Done!"
else
    SUCCESS=0
    echo "Database already exists, skipping provisioning..."
fi

if [ $SUCCESS -ne 0 ]; then
    echo "Failed to initialize database..."
    exit 1
else
    echo "Database initialized!"
fi

exit $SUCCESS
