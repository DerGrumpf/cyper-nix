#!/usr/bin/env bash
# Usage: sudo ./restore.sh gitea_dump_*.sql gitea_data_*.tar.gz
set -euo pipefail

SQL_DUMP="${1:?provide the .sql dump as first argument}"
DATA_ARCHIVE="${2:?provide the data .tar.gz as second argument}"

GITEA_HOME="/var/lib/gitea"
GITEA_USER="gitea"
DB_NAME="gitea"
DB_USER="gitea"

echo "[1/5] Stopping gitea..."
systemctl stop gitea

echo "[2/5] Waiting for postgres..."
until sudo -u postgres psql -c '\q' 2>/dev/null; do sleep 1; done

echo "[3/5] Restoring database..."
sudo -u postgres psql -c "DROP DATABASE IF EXISTS ${DB_NAME};"
sudo -u postgres psql -c "CREATE DATABASE ${DB_NAME} OWNER ${DB_USER};"
sudo -u postgres psql -d "$DB_NAME" < "$SQL_DUMP"
echo "      done."

echo "[4/5] Restoring gitea data..."
# data/gitea from the docker volume -> /var/lib/gitea
tar xzf "$DATA_ARCHIVE" --strip-components=2 -C "$GITEA_HOME" ./data/gitea

# ssh host keys -> /var/lib/gitea/ssh
mkdir -p "$GITEA_HOME/ssh"
tar xzf "$DATA_ARCHIVE" --strip-components=1 -C "$GITEA_HOME/ssh" ./ssh

chown -R "$GITEA_USER":"$GITEA_USER" "$GITEA_HOME"
echo "      done."

echo "[5/5] Starting gitea..."
systemctl start gitea
systemctl status gitea --no-pager
