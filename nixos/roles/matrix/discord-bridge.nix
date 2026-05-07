{ config, lib, ... }:
{
  nixpkgs.config.permittedInsecurePackages = [ "olm-3.2.16" ];

  sops.secrets.discord_bot_token = {
    owner = "mautrix-discord";
    group = "mautrix-discord";
  };
  sops.secrets.discord_client_id = {
    owner = "mautrix-discord";
    group = "mautrix-discord";
  };

  systemd.services.mautrix-discord-env = {
    before = [ "mautrix-discord-registration.service" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      mkdir -p /run/mautrix-discord
      echo "DISCORD_BOT_TOKEN=$(cat ${config.sops.secrets.discord_bot_token.path})" > /run/mautrix-discord/env
      echo "DISCORD_CLIENT_ID=$(cat ${config.sops.secrets.discord_client_id.path})" >> /run/mautrix-discord/env
      chmod 600 /run/mautrix-discord/env
      chown mautrix-discord:mautrix-discord /run/mautrix-discord/env
    '';
  };

  services.postgresql = {
    ensureUsers = [
      {
        name = "mautrix-discord";
        ensureDBOwnership = true;
      }
    ];
    ensureDatabases = [ "mautrix-discord" ];
  };

  services.mautrix-discord = {
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
      };
      discord = {
        client_id = "$DISCORD_CLIENT_ID";
        bot_token = "$DISCORD_BOT_TOKEN";
      };
    };
  };
  systemd.services.mautrix-discord-registration.serviceConfig.UMask = lib.mkForce "0022";
}
