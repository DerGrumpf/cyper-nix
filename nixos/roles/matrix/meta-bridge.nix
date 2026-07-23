{ config, lib, ... }:
{
  sops.secrets = {
    "matrix/bridges/meta/as_token" = {
      owner = "mautrix-meta-facebook";
      group = "mautrix-meta";
    };
    "matrix/bridges/meta/hs_token" = {
      owner = "mautrix-meta-facebook";
      group = "mautrix-meta";
    };
    "matrix/bridges/instagram/as_token" = {
      owner = "mautrix-meta-instagram";
      group = "mautrix-meta";
    };
    "matrix/bridges/instagram/hs_token" = {
      owner = "mautrix-meta-instagram";
      group = "mautrix-meta";
    };
  };

  environment.persistence."/persist".directories = [
    {
      directory = "/var/lib/mautrix-meta-facebook";
      user = "mautrix-meta-facebook";
      group = "mautrix-meta";
      mode = "0750";
    }
    {
      directory = "/var/lib/mautrix-meta-instagram";
      user = "mautrix-meta-instagram";
      group = "mautrix-meta";
      mode = "0750";
    }
  ];

  systemd.services = {
    mautrix-meta-facebook-env = {
      before = [ "mautrix-meta-facebook-registration.service" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
      };
      script = ''
        mkdir -p /run/mautrix-meta-facebook
        echo "META_AS_TOKEN=$(cat ${
          config.sops.secrets."matrix/bridges/meta/as_token".path
        })" > /run/mautrix-meta-facebook/env
        echo "META_HS_TOKEN=$(cat ${
          config.sops.secrets."matrix/bridges/meta/hs_token".path
        })" >> /run/mautrix-meta-facebook/env
        chmod 600 /run/mautrix-meta-facebook/env
        chown mautrix-meta-facebook:mautrix-meta /run/mautrix-meta-facebook/env
      '';
    };

    mautrix-meta-instagram-env = {
      before = [ "mautrix-meta-instagram-registration.service" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
      };
      script = ''
        mkdir -p /run/mautrix-meta-instagram
        echo "INSTAGRAM_AS_TOKEN=$(cat ${
          config.sops.secrets."matrix/bridges/instagram/as_token".path
        })" > /run/mautrix-meta-instagram/env
        echo "INSTAGRAM_HS_TOKEN=$(cat ${
          config.sops.secrets."matrix/bridges/instagram/hs_token".path
        })" >> /run/mautrix-meta-instagram/env
        chmod 600 /run/mautrix-meta-instagram/env
        chown mautrix-meta-instagram:mautrix-meta /run/mautrix-meta-instagram/env
      '';
    };

    mautrix-meta-facebook-registration.serviceConfig.UMask = lib.mkForce "0022";
    mautrix-meta-instagram-registration.serviceConfig.UMask = lib.mkForce "0022";
  };

  services = {
    postgresql = {
      ensureUsers = [
        {
          name = "mautrix-meta-facebook";
          ensureDBOwnership = true;
        }
        {
          name = "mautrix-meta-instagram";
          ensureDBOwnership = true;
        }
      ];
      ensureDatabases = [
        "mautrix-meta-facebook"
        "mautrix-meta-instagram"
      ];
    };

    mautrix-meta.instances = {
      facebook = {
        enable = true;
        environmentFile = "/run/mautrix-meta-facebook/env";
        settings = {
          homeserver = {
            address = "http://127.0.0.1:8008";
            domain = "cyperpunk.de";
          };
          database = {
            type = "postgres";
            uri = "postgres:///mautrix-meta-facebook?host=/run/postgresql&sslmode=disable";
          };
          appservice = {
            as_token = "$META_AS_TOKEN";
            hs_token = "$META_HS_TOKEN";
          };
          bridge.permissions = {
            "cyperpunk.de" = "user";
            "@dergrumpf:cyperpunk.de" = "admin";
          };
        };
      };

      instagram = {
        enable = true;
        environmentFile = "/run/mautrix-meta-instagram/env";
        settings = {
          homeserver = {
            address = "http://127.0.0.1:8008";
            domain = "cyperpunk.de";
          };
          database = {
            type = "postgres";
            uri = "postgres:///mautrix-meta-instagram?host=/run/postgresql&sslmode=disable";
          };
          appservice = {
            as_token = "$INSTAGRAM_AS_TOKEN";
            hs_token = "$INSTAGRAM_HS_TOKEN";
          };
          bridge.permissions = {
            "cyperpunk.de" = "user";
            "@dergrumpf:cyperpunk.de" = "admin";
          };
        };
      };
    };
  };
}
