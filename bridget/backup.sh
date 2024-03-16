
#!/usr/bin/env bash
set -euxo pipefail
VAULTWARDEN_DATA_DIR="/var/lib/docker/volumes/vaultwarden_vaultwarden/_data"
CONDUIT_DATA_DIR="/var/lib/docker/volumes/conduit_data/_data/conduit.db"

source %%SECRETS_FILE%%

TEMP_DIR="/backup-temp-$(date +%s)"

trap "%%CURL_BIN%% -m 10 --retry 5 $HCPING_URL/fail; rm -rf $TEMP_DIR" ERR

%%CURL_BIN%% -m 10 --retry 5 $HCPING_URL/start

mkdir "$TEMP_DIR"


mkdir "$TEMP_DIR/vaultwarden"

%%SQLITE3_BIN%% "$VAULTWARDEN_DATA_DIR/db.sqlite3" "VACUUM INTO '$TEMP_DIR/vaultwarden/db.sqlite3'"
cp --reflink=auto -r "$VAULTWARDEN_DATA_DIR/attachments/" "$TEMP_DIR/vaultwarden/attachments/"
cp --reflink=auto $VAULTWARDEN_DATA_DIR/rsa_key* "$TEMP_DIR/vaultwarden/"

mkdir "$TEMP_DIR/mastodon"
%%DOCKER_BIN%% exec mastodon-db-1 pg_dumpall -O -U postgres > $TEMP_DIR/mastodon/db.sql

mkdir "$TEMP_DIR/ory"
%%DOCKER_BIN%% exec ory-postgres-1 pg_dumpall -O -U postgres > $TEMP_DIR/ory/db.sql

mkdir "$TEMP_DIR/conduit"
%%SQLITE3_BIN%% "$CONDUIT_DATA_DIR/conduit.db" "VACUUM INTO '$TEMP_DIR/conduit/conduit.db'"
cp --reflink=auto -r "$CONDUIT_DATA_DIR/media/" "$TEMP_DIR/conduit/media/"

%%RESTIC_BIN%% backup "$TEMP_DIR"

%%RESTIC_BIN%% forget --keep-last 10 --keep-weekly 4 --keep-monthly 12 --group-by ""
%%RESTIC_BIN%% prune

rm -rf "$TEMP_DIR"

%%CURL_BIN%% -m 10 --retry 5 $HCPING_URL