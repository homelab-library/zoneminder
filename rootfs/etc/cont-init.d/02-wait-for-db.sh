#!/usr/bin/with-contenv bash
set -Eeuo pipefail

SUCCESS=2
COUNT=0

while [[ $COUNT -le 60 && SUCCESS -ne 0 ]]; do
    sleep 1
    echo "${COUNT}: Waiting for database..."
    echo 'select 1' | mysql "-u${ZM_DB_USER}" "-p${ZM_DB_PASS}" "-h${ZM_DB_HOST}" &>/dev/null &&
        SUCCESS=0
    COUNT=$(($COUNT + 1))
done

exit $SUCCESS
