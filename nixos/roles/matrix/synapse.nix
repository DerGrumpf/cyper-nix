{
  config,
  pkgs,
  lib,
  ...
}:
let
  wellKnownMatrix = {
    "= /.well-known/matrix/client" = {
      extraConfig = ''
        default_type application/json;
        add_header Access-Control-Allow-Origin *;
        return 200 '{"m.homeserver":{"base_url":"https://matrix.cyperpunk.de"},"org.matrix.msc4143.rtc_foci":[{"type":"livekit","livekit_service_url":"https://cyperpunk.de/livekit/jwt/"}]}';
      '';
    };
    "= /.well-known/matrix/server" = {
      extraConfig = ''
        default_type application/json;
        add_header Access-Control-Allow-Origin *;
        return 200 '{"m.server":"matrix.cyperpunk.de:443"}';
      '';
    };
  };

  synapseAdmin = pkgs.ketesa.withConfig {
    restrictBaseUrl = [ "https://matrix.cyperpunk.de" ];
    loginFlows = [ "password" ];
  };

  matrixIndexHtml = pkgs.writeText "matrix-index.html" (builtins.readFile ./index.html);
  matrixRegisterPhp = pkgs.writeText "matrix-register.php" (builtins.readFile ./register.php);
  matrixStyleCss = pkgs.writeText "matrix-style.css" (builtins.readFile ./style.css);
  matrixAppJs = pkgs.writeText "matrix-app.js" (builtins.readFile ./app.js);
in
{
  sops.secrets = {
    "matrix/macaroon_secret" = { };
    "matrix/registration_secret" = {
      owner = "matrix-synapse";
      group = "matrix-synapse";
    };
    "postgres/replication_password" = {
      owner = "postgres";
      group = "postgres";
    };
    "kanidm/synapse_secret" = {
      owner = "matrix-synapse";
      group = "matrix-synapse";
    };
  };

  environment.persistence."/persist".directories = [
    {
      directory = "/var/lib/matrix-synapse";
      user = "matrix-synapse";
      group = "matrix-synapse";
      mode = "0700";
    }
    {
      directory = "/var/lib/postgresql";
      user = "postgres";
      group = "postgres";
      mode = "0750";
    }
    {
      directory = "/var/lib/acme";
      user = "acme";
      group = "acme";
      mode = "0755";
    }
  ];

  services = {

    phpfpm.pools.matrix = {
      user = "nginx";
      group = "nginx";
      settings = {
        "listen.owner" = "nginx";
        "listen.group" = "nginx";
        "pm" = "dynamic";
        "pm.max_children" = 10;
        "pm.start_servers" = 2;
        "pm.min_spare_servers" = 1;
        "pm.max_spare_servers" = 3;
      };
      phpPackage = pkgs.php.withExtensions ({ enabled, all }: enabled ++ [ all.curl ]);
    };

    matrix-synapse = {
      enable = true;
      settings = {
        server_name = "cyperpunk.de";
        public_baseurl = "https://matrix.cyperpunk.de";
        enable_registration = false;
        trusted_key_servers = [ { server_name = "matrix.org"; } ];
        suppress_key_server_warning = true;
        registration_shared_secret_path = config.sops.secrets."matrix/registration_secret".path;
        macaroon_secret_key = "$__file{${config.sops.secrets."matrix/macaroon_secret".path}}";
        matrix_rtc = {
          enabled = true;
          transports = [
            {
              type = "livekit";
              livekit_service_url = "https://cyperpunk.de/livekit/jwt/";
            }
          ];
        };

        rc_login = {
          address = {
            per_second = 0.17;
            burst_count = 10;
          };
          account = {
            per_second = 0.17;
            burst_count = 10;
          };
          failed_attempts = {
            per_second = 0.17;
            burst_count = 10;
          };
        };

        listeners = [
          {
            port = 8008;
            bind_addresses = [
              "127.0.0.1"
              "::1"
            ];
            type = "http";
            tls = false;
            x_forwarded = true;
            resources = [
              {
                names = [
                  "client"
                  "federation"
                  "openid"
                ];
                compress = true;
              }
            ];
          }
          {
            port = 9009;
            tls = false;
            type = "metrics";
            bind_addresses = [
              "127.0.0.1"
              "10.10.0.1"
            ];
            resources = [ ];
          }
        ];
        enable_metrics = true;

        oidc_providers = [
          {
            idp_id = "kanidm";
            idp_name = "Kanidm";
            issuer = "https://auth.cyperpunk.de/oauth2/openid/synapse";
            client_id = "synapse";
            client_secret_path = config.sops.secrets."kanidm/synapse_secret".path;
            scopes = [
              "openid"
              "profile"
              "email"
            ];
            allow_existing_users = true;
            user_mapping_provider.config = {
              localpart_template = "{{ user.preferred_username.split('@')[0] }}";
              display_name_template = "{{ user.displayname }}";
            };
          }
        ];
      };
    };

    nginx.virtualHosts = {
      "cyperpunk.de" = {
        forceSSL = true;
        enableACME = true;
        serverAliases = [ "matrix.cyperpunk.de" ];
        http2 = true;
        locations = wellKnownMatrix // {
          "/_matrix".proxyPass = "http://127.0.0.1:8008";
          "/_synapse/client".proxyPass = "http://127.0.0.1:8008";
          "/_synapse/admin".proxyPass = "http://127.0.0.1:8008";
          "/metrics" = {
            proxyPass = "http://127.0.0.1:9009";
            extraConfig = ''
              allow 127.0.0.1;
              deny all;
            '';
          };
          "/admin/" = {
            alias = "${synapseAdmin}/";
            tryFiles = "$uri $uri/ /admin/index.html";
          };
          "^~ /livekit/jwt/" = {
            priority = 400;
            proxyPass = "http://127.0.0.1:${toString config.services.lk-jwt-service.port}/";
          };
          "^~ /livekit/sfu/" = {
            priority = 400;
            proxyPass = "http://127.0.0.1:${toString config.services.livekit.settings.port}/";
            proxyWebsockets = true;
            extraConfig = ''
              proxy_send_timeout 120;
              proxy_read_timeout 120;
              proxy_buffering off;
              proxy_set_header Accept-Encoding gzip;
              proxy_set_header Upgrade $http_upgrade;
              proxy_set_header Connection "upgrade";
            '';
          };
          "/" = {
            root = "/var/www/matrix";
            extraConfig = ''
              index index.html;
              try_files $uri $uri/ =404;
            '';
          };
          "~ \\.php$" = {
            root = "/var/www/matrix";
            extraConfig = ''
              fastcgi_pass unix:${config.services.phpfpm.pools.matrix.socket};
              fastcgi_index index.php;
              include ${pkgs.nginx}/conf/fastcgi_params;
              fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
            '';
          };
        };
      };
    };

    postgresql = {
      enable = true;
      initialScript = pkgs.writeText "synapse-init.sql" ''
        CREATE ROLE "matrix-synapse" WITH LOGIN PASSWORD 'synapse';
        CREATE ROLE replicator WITH REPLICATION LOGIN;
        CREATE DATABASE "matrix-synapse" WITH OWNER "matrix-synapse"
          TEMPLATE template0
          LC_COLLATE = "C"
          LC_CTYPE = "C";
      '';
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

  systemd = {
    services = {
      matrix-synapse.serviceConfig.ReadOnlyPaths = [
        "/var/lib/mautrix-discord"
        "/var/lib/mautrix-whatsapp"
      ];
      postgresql.postStart = lib.mkAfter ''
        PG_PASS=$(cat ${config.sops.secrets."postgres/replication_password".path})
        ${config.services.postgresql.package}/bin/psql -U postgres -c \
          "ALTER ROLE replicator WITH PASSWORD '$PG_PASS';"
      '';
    };

    tmpfiles.rules = [
      "d /var/www/matrix            0755 nginx nginx -"
      "L+ /var/www/matrix/index.html   0644 nginx nginx - ${matrixIndexHtml}"
      "L+ /var/www/matrix/register.php 0644 nginx nginx - ${matrixRegisterPhp}"
      "L+ /var/www/matrix/style.css  0644 nginx nginx - ${matrixStyleCss}"
      "L+ /var/www/matrix/app.js     0644 nginx nginx - ${matrixAppJs}"
    ];
  };

}
