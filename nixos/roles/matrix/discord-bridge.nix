{ config, lib, ... }:
{
  sops.secrets = {
    "matrix/bridges/discord/bot_token" = {
      owner = "mautrix-discord";
      group = "mautrix-discord";
    };
    "matrix/bridges/discord/client_id" = {
      owner = "mautrix-discord";
      group = "mautrix-discord";
    };
    "matrix/bridges/discord/pickle_key" = {
      owner = "mautrix-discord";
      group = "mautrix-discord";
    };
  };

  environment.persistence."/persist".directories = [
    {
      directory = "/var/lib/mautrix-discord";
      user = "mautrix-discord";
      group = "mautrix-discord";
      mode = "0750";
    }
  ];

  systemd = {
    services = {
      mautrix-discord-env = {
        before = [ "mautrix-discord-registration.service" ];
        wantedBy = [ "multi-user.target" ];
        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = true;
        };
        script = ''
          mkdir -p /run/mautrix-discord
          echo "DISCORD_BOT_TOKEN=$(cat ${
            config.sops.secrets."matrix/bridges/discord/bot_token".path
          })" > /run/mautrix-discord/env
          echo "DISCORD_CLIENT_ID=$(cat ${
            config.sops.secrets."matrix/bridges/discord/client_id".path
          })" >> /run/mautrix-discord/env
          echo "DISCORD_PICKLE_KEY=$(cat ${
            config.sops.secrets."matrix/bridges/discord/pickle_key".path
          })" >> /run/mautrix-discord/env
          chmod 600 /run/mautrix-discord/env
          chown mautrix-discord:mautrix-discord /run/mautrix-discord/env
        '';
      };

      mautrix-discord-registration.serviceConfig.UMask = lib.mkForce "0750";
    };
    tmpfiles.rules = [
      "z /var/lib/mautrix-discord/discord-registration.yaml 0640 mautrix-discord mautrix-discord -"
    ];
  };

  services = {
    postgresql = {
      ensureUsers = [
        {
          name = "mautrix-discord";
          ensureDBOwnership = true;
        }
      ];
      ensureDatabases = [ "mautrix-discord" ];
    };

    mautrix-discord = {
      enable = true;
      environmentFile = "/run/mautrix-discord/env";
      settings = {
        homeserver = {
          address = "http://127.0.0.1:8008";
          domain = "cyperpunk.de";
        };
        appservice.database = {
          type = "postgres";
          uri = "postgres:///mautrix-discord?host=/run/postgresql&sslmode=disable";
        };
        bridge = {
          permissions = {
            "cyperpunk.de" = "user";
            "@dergrumpf:cyperpunk.de" = "admin";
          };

          backfill = {
            limits = {
              initial = {
                channel = 10000;
                thread = 500;
              };
              missed = {
                channel = 500;
              };
            };
          };
          encryption = {
            allow = true;
            default = true;
            pickle_key = "$DISCORD_PICKLE_KEY";
            verification_levels = {
              receive = "unverified";
              send = "unverified";
              share = "cross-signed-tofu";
            };
          };
        };
        discord = {
          client_id = "$DISCORD_CLIENT_ID";
          bot_token = "$DISCORD_BOT_TOKEN";
        };
      };
    };
  };

  users.users.matrix-synapse.extraGroups = [ "mautrix-discord" ];
}
