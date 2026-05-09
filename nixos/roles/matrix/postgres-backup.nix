{
  config,
  pkgs,
  lib,
  ...
}:
{
  sops.secrets = {
    pg_replication_password = {
      owner = "postgres";
      group = "postgres";
    };
  };

  services.postgresql = {
    enable = true;
    package = pkgs.postgresql_15; # must match cyper-proxy's PG version exactly

    settings = {
      hot_standby = true;
      hot_standby_feedback = true;
      max_standby_streaming_delay = "30s";
      listen_addresses = "127.0.0.1"; # only local, no external exposure
      wal_receiver_timeout = "60s";
      recovery_min_apply_delay = "0"; # set e.g. "1h" for a delayed safety replica
    };
  };

  # Writes standby.signal and primary_conninfo before PostgreSQL starts.
  systemd.services.postgresql = {
    preStart = lib.mkAfter ''
      DATADIR="${config.services.postgresql.dataDir}"
      PG_PASS=$(cat ${config.sops.secrets.pg_replication_password.path})

      # Tell Postgres to start as a hot standby
      if [ ! -f "$DATADIR/standby.signal" ]; then
        touch "$DATADIR/standby.signal"
        chown postgres:postgres "$DATADIR/standby.signal"
      fi

      # primary_conninfo via Tailscale — no public IP involved
      CONNINFO="host=100.109.10.91 port=5432 user=replicator password=$PG_PASS application_name=cyper-controller sslmode=require"

      grep -v "^primary_conninfo" "$DATADIR/postgresql.auto.conf" 2>/dev/null > /tmp/auto.conf.tmp || true
      echo "primary_conninfo = '$CONNINFO'" >> /tmp/auto.conf.tmp
      mv /tmp/auto.conf.tmp "$DATADIR/postgresql.auto.conf"
      chown postgres:postgres "$DATADIR/postgresql.auto.conf"
    '';
  };

  # Run once manually to seed the standby: systemctl start postgresql-basebackup
  # Do NOT add it to wantedBy — it would wipe the data dir on every reboot.
  systemd.services.postgresql-basebackup = {
    description = "Bootstrap PostgreSQL standby via pg_basebackup from cyper-proxy";
    requires = [
      "network-online.target"
      "tailscaled.service"
    ];
    after = [
      "network-online.target"
      "tailscaled.service"
    ];

    serviceConfig = {
      Type = "oneshot";
      User = "postgres";
      RemainAfterExit = false;
    };

    script = ''
      DATADIR="${config.services.postgresql.dataDir}"
      PG_PASS=$(cat ${config.sops.secrets.pg_replication_password.path})

      if [ -d "$DATADIR/global" ]; then
        echo "Data directory already exists — skipping."
        echo "Remove $DATADIR manually to force a re-initialise."
        exit 0
      fi

      echo "Running pg_basebackup from cyper-proxy via Tailscale..."
      PGPASSWORD="$PG_PASS" ${config.services.postgresql.package}/bin/pg_basebackup \
        --host=100.109.10.91 \
        --port=5432 \
        --username=replicator \
        --pgdata="$DATADIR" \
        --wal-method=stream \
        --write-recovery-conf \
        --checkpoint=fast \
        --progress \
        --verbose

      chown -R postgres:postgres "$DATADIR"
      chmod 0700 "$DATADIR"
      echo "Done. Start postgresql.service to begin streaming replication."
    '';
  };

  # Block any external access to postgres on the public interface
  networking.firewall = {
    interfaces."tailscale0".allowedTCPPorts = [ ]; # replication is outbound only
  };
}
