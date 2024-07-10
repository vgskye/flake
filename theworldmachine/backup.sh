#!/usr/bin/env bash
set -euxo pipefail

SYNAPSE_DATA_DIR="/var/lib/docker/volumes/synapse_data/_data"

TEMP_DIR="/tmp/backups-$(date +%s)"

trap "curl -m 10 --retry 5 $HCPING_URL/fail; rm -rf $TEMP_DIR" ERR

curl -m 10 --retry 5 $HCPING_URL/start

mkdir "$TEMP_DIR"

for db in keycloak sharkey synapse
do
  docker exec $db-db-1 pg_dumpall -O -U $db > $TEMP_DIR/$db.sql
done

cp --reflink=auto -r $SYNAPSE_DATA_DIR "$TEMP_DIR/synapse"

mkdir $TEMP_DIR/mailcow
MAILCOW_BACKUP_LOCATION="$TEMP_DIR/mailcow" /opt/mailcow-dockerized/helper-scripts/backup_and_restore.sh backup all

restic backup "$TEMP_DIR"

restic forget --keep-last 4 --keep-weekly 4 --keep-monthly 12 --group-by ""
restic prune

rm -rf "$TEMP_DIR"

curl -m 10 --retry 5 $HCPING_URL