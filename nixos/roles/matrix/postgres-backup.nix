{
  config,
  pkgs,
  lib,
  ...
}:
{
  sops.secrets = {
    pg_replication_password = {
      owner = "root";
      group = "root";
    };
  };

  virtualisation.docker.enable = true;

  systemd.services.postgresql-replica = {
    description = "PostgreSQL WAL streaming replica (Docker)";
    requires = [
      "docker.service"
      "tailscaled.service"
      "network-online.target"
    ];
    after = [
      "docker.service"
      "tailscaled.service"
      "network-online.target"
    ];
    wantedBy = [ "multi-user.target" ];

    serviceConfig = {
      Type = "simple";
      Restart = "on-failure";
      RestartSec = "10s";
    };

    preStart = ''
            DATADIR="/storage/backup/postgresql-replica"
            PG_PASS=$(cat ${config.sops.secrets.pg_replication_password.path})

            ${pkgs.docker}/bin/docker pull postgres:17

            if [ ! -f "$DATADIR/PG_VERSION" ]; then
              echo "No data dir found — running pg_basebackup..."
              rm -rf "$DATADIR"

              ${pkgs.docker}/bin/docker run --rm \
                -e PGPASSWORD="$PG_PASS" \
                -v "/storage/backup:/out" \
                --network host \
                postgres:17 \
                pg_basebackup \
                  --host=100.109.10.91 \
                  --port=5432 \
                  --username=replicator \
                  --pgdata=/out/postgresql-replica \
                  --wal-method=stream \
                  --checkpoint=fast \
                  --progress \
                  --verbose

              # standby signal
              touch "$DATADIR/standby.signal"

              # primary conninfo
              cat > "$DATADIR/postgresql.auto.conf" <<EOF
      primary_conninfo = 'host=100.109.10.91 port=5432 user=replicator password=$PG_PASS application_name=cyper-controller sslmode=require'
      EOF

              # minimal postgresql.conf
              cat > "$DATADIR/postgresql.conf" <<EOF
      hot_standby = on
      hot_standby_feedback = on
      wal_receiver_timeout = '60s'
      port = 5434
      listen_addresses = '*'
      EOF

              chown -R 999:999 "$DATADIR"
            fi

            # ensure postgresql.conf exists on subsequent starts
            if [ ! -f "$DATADIR/postgresql.conf" ]; then
              cat > "$DATADIR/postgresql.conf" <<EOF
      hot_standby = on
      hot_standby_feedback = on
      wal_receiver_timeout = '60s'
      port = 5434
      listen_addresses = '*'
      EOF
              chown 999:999 "$DATADIR/postgresql.conf"
            fi
    '';

    script = ''
      ${pkgs.docker}/bin/docker run --rm \
        --name postgresql-replica \
        -v /storage/backup/postgresql-replica:/var/lib/postgresql/data \
        --network host \
        postgres:17
    '';

    postStop = ''
      ${pkgs.docker}/bin/docker rm -f postgresql-replica 2>/dev/null || true
    '';
  };

  services.prometheus.exporters.postgres = {
    enable = true;
    port = 9188;
    runAsLocalSuperUser = false;
    dataSourceName = "postgresql://postgres@localhost:5434/postgres?sslmode=disable";
  };
}
