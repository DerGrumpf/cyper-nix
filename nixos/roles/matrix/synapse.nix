{
  config,
  pkgs,
  ...
}:
let
  wellKnownMatrix = {
    "= /.well-known/matrix/client" = {
      extraConfig = ''
        default_type application/json;
        add_header Access-Control-Allow-Origin *;
        return 200 '{"m.homeserver":{"base_url":"https://matrix.cyperpunk.de"}}';
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
in
{
  sops.secrets = {
    matrix_macaroon_secret = { };
    matrix_registration_secret = {
      owner = "matrix-synapse";
      group = "matrix-synapse";
    };
  };

  services = {
    matrix-synapse = {
      enable = true;
      settings = {
        server_name = "cyperpunk.de";
        public_baseurl = "https://matrix.cyperpunk.de";
        enable_registration = false;
        trusted_key_servers = [ { server_name = "matrix.org"; } ];
        suppress_key_server_warning = true;
        registration_shared_secret_path = config.sops.secrets.matrix_registration_secret.path;
        macaroon_secret_key = "$__file{${config.sops.secrets.matrix_macaroon_secret.path}}";

        #experimental_features = {
        #  msc3266_enabled = true;
        #  msc3779_enabled = true;
        #  msc3401_enabled = true;
        #  msc4143_enabled = true;
        #  msc4195_enabled = true;
        #  msc4222_enabled = true;
        #};

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
            bind_addresses = [ "127.0.0.1" ];
            resources = [ ];
          }
        ];
        enable_metrics = true;
      };
    };

    nginx.virtualHosts = {
      # Matrix homeserver
      "cyperpunk.de" = {
        forceSSL = true;
        enableACME = true;
        serverAliases = [ "matrix.cyperpunk.de" ];
        http2 = true;
        locations = wellKnownMatrix // {
          "/_matrix".proxyPass = "http://127.0.0.1:8008";
          "/_synapse/client".proxyPass = "http://127.0.0.1:8008";
          "/metrics" = {
            proxyPass = "http://127.0.0.1:9009";
            extraConfig = ''
              allow 127.0.0.1;
              deny all;
            '';
          };
          "/admin/" = {
            root = "${synapseAdmin}";
            #tryFiles = "$uri $uri/ /index.html";
          };
        };
      };
    };

    postgresql = {
      enable = true;
      initialScript = pkgs.writeText "synapse-init.sql" ''
        CREATE ROLE "matrix-synapse" WITH LOGIN PASSWORD 'synapse';
        CREATE DATABASE "matrix-synapse" WITH OWNER "matrix-synapse"
          TEMPLATE template0
          LC_COLLATE = "C"
          LC_CTYPE = "C";
      '';
    };
  };
}
