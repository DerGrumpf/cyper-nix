{
  lib,
  pkgs,
  config,
  ...
}:
{
  sops.secrets = {
    "postgres/synapse" = {
      owner = "postgres";
      group = "postgres";
    };
    "postgres/maubot" = {
      owner = "postgres";
      group = "postgres";
    };
    "postgres/mautrix/discord" = {
      owner = "postgres";
      group = "postgres";
    };
    "postgres/mautrix/whatsapp" = {
      owner = "postgres";
      group = "postgres";
    };
    "postgres/mautrix/facebook" = {
      owner = "postgres";
      group = "postgres";
    };
    "postgres/mautrix/instagram" = {
      owner = "postgres";
      group = "postgres";
    };
    "services/mastodon/db_password" = {
      owner = "postgres";
      group = "postgres";
    };
  };

  networking.firewall.interfaces.wg0.allowedTCPPorts = [ 5432 ];

  services = {
    postgresql = {
      enable = true;
      package = pkgs.postgresql_17;
      dataDir = "/storage/backup/postgresql-data";
      settings = {
        listen_addresses = lib.mkForce "127.0.0.1,10.10.0.2";
        ssl = false;
      };

      authentication = lib.mkForce ''
        local all all trust
        host  all all 127.0.0.1/32 md5
        host  all all ::1/128      md5
        host  all  all  10.10.0.1/32  scram-sha-256
      '';

      ensureUsers = [
        {
          name = "matrix-synapse";
          ensureDBOwnership = true;
        }
        {
          name = "mastodon";
          ensureDBOwnership = true;
        }
        {
          name = "maubot";
          ensureDBOwnership = true;
        }
        {
          name = "mautrix-discord";
          ensureDBOwnership = true;
        }
        {
          name = "mautrix-whatsapp";
          ensureDBOwnership = true;
        }
        {
          name = "mautrix-meta-facebook";
          ensureDBOwnership = true;
        }
        {
          name = "mautrix-meta-instagram";
          ensureDBOwnership = true;
        }
        {
          name = "forgejo";
          ensureDBOwnership = true;
        }
      ];

      ensureDatabases = [
        "matrix-synapse"
        "mastodon"
        "forgejo"
        "maubot"
        "mautrix-discord"
        "mautrix-whatsapp"
        "mautrix-meta-facebook"
        "mautrix-meta-instagram"
      ];
    };

    prometheus.exporters.postgres = {
      enable = true;
      port = 9188;
      runAsLocalSuperUser = true;
      dataSourceName = "postgresql:///postgres?host=/run/postgresql&sslmode=disable";
    };
  };

  systemd.services.postgresql-set-passwords = {
    description = "Set postgres role passwords from sops secrets";
    after = [ "postgresql-setup.service" ];
    requires = [ "postgresql-setup.service" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      User = "postgres";
    };
    script = ''
      ${config.services.postgresql.package}/bin/psql -U postgres -c "
        ALTER ROLE \"matrix-synapse\" WITH PASSWORD '$(cat ${
          config.sops.secrets."postgres/synapse".path
        })';
        ALTER ROLE mastodon WITH PASSWORD '$(cat ${
          config.sops.secrets."services/mastodon/db_password".path
        })';
        ALTER ROLE maubot WITH PASSWORD '$(cat ${config.sops.secrets."postgres/maubot".path})';
        ALTER ROLE \"mautrix-discord\" WITH PASSWORD '$(cat ${
          config.sops.secrets."postgres/mautrix/discord".path
        })';
        ALTER ROLE \"mautrix-whatsapp\" WITH PASSWORD '$(cat ${
          config.sops.secrets."postgres/mautrix/whatsapp".path
        })';
        ALTER ROLE \"mautrix-meta-facebook\" WITH PASSWORD '$(cat ${
          config.sops.secrets."postgres/mautrix/facebook".path
        })';
        ALTER ROLE \"mautrix-meta-instagram\" WITH PASSWORD '$(cat ${
          config.sops.secrets."postgres/mautrix/instagram".path
        })';
        ALTER ROLE forgejo WITH PASSWORD '$(cat ${
          config.sops.secrets."services/forgejo/db_password".path
        })';
      "
    '';
  };
}
