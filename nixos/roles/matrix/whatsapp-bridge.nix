{ config, ... }:
{
  sops.secrets."postgres/mautrix/whatsapp" = {
    owner = "mautrix-whatsapp";
    group = "mautrix-whatsapp";
  };

  environment.persistence."/persist".directories = [
    {
      directory = "/var/lib/mautrix-whatsapp";
      user = "mautrix-whatsapp";
      group = "mautrix-whatsapp";
      mode = "0750";
    }
  ];

  systemd.services.mautrix-whatsapp-env = {
    before = [ "mautrix-whatsapp.service" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      mkdir -p /run/mautrix-whatsapp
      echo "WHATSAPP_DB_PASSWORD=$(cat ${
        config.sops.secrets."postgres/mautrix/whatsapp".path
      })" > /run/mautrix-whatsapp/env
      chmod 600 /run/mautrix-whatsapp/env
      chown mautrix-whatsapp:mautrix-whatsapp /run/mautrix-whatsapp/env
    '';
  };

  services.mautrix-whatsapp = {
    enable = true;
    environmentFile = "/run/mautrix-whatsapp/env";
    settings = {
      homeserver = {
        address = "http://127.0.0.1:8008";
        domain = "cyperpunk.de";
      };
      database = {
        type = "postgres";
        uri = "postgres://mautrix-whatsapp:$WHATSAPP_DB_PASSWORD@10.10.0.2:5432/mautrix-whatsapp?sslmode=disable";
      };
      bridge.permissions = {
        "cyperpunk.de" = "user";
        "@dergrumpf:cyperpunk.de" = "admin";
      };
    };
  };
}
