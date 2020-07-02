#!/usr/bin/env bash
RUNDIR="/var/run/zm"
TMPDIR="/tmp/zm"

mkdir -p "$RUNDIR"
chown www-data:www-data "$RUNDIR"
mkdir -p "$TMPDIR"
chown www-data:www-data "$TMPDIR"

zmpkg.pl start
