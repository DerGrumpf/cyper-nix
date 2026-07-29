{ lib, ... }: {
  services = {
    postgresql = {
      enable = true;

      settings = {
        wal_level = "replica";
        max_wal_senders = 5;
        wal_keep_size = "512MB";
        listen_addresses = lib.mkForce "127.0.0.1,10.10.0.1";
        ssl = true;
      };
      authentication = lib.mkAfter ''
        hostssl replication replicator 10.10.0.2/32 scram-sha-256
      '';
    };

    prometheus.exporters.postgres = {
      enable = true;
      port = 9188;
      runAsLocalSuperUser = true;
      dataSourceName = "postgresql:///postgres?host=/run/postgresql&sslmode=disable";
    };
  };

  environment.persistence."/persist".directories = [
    {
      directory = "/var/lib/postgresql";
      user = "postgres";
      group = "postgres";
      mode = "0750";
    }
  ];
}
