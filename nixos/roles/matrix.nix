{ pkgs, config, ... }:
let
  serverIP = builtins.head (
    builtins.match "([0-9.]+)/.*" config.systemd.network.networks."10-ethernet".networkConfig.Address
  );
in
{
  networking.firewall.allowedTCPPorts = [
    8448
    8080
  ];

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
        public_baseurl = "http://matrix.cyperpunk.de";
        enable_registration = false; # TODO: disable
        enable_registration_without_verfication = true;
        trusted_key_servers = [ { server_name = "matrix.org"; } ];
        suppress_key_server_warning = true;
        registration_shared_secret_path = config.sops.secrets.matrix_registration_secret.path;
        macaroon_secret_key = "$__file{${config.sops.secrets.matrix_macaroon_secret.path}}";
        listeners = [
          {
            port = 8008;
            bind_addresses = [ "127.0.0.1" ];
            type = "http";
            tls = false;
            x_forwarded = true;
            resources = [
              {
                names = [
                  "client"
                  "federation"
                ];
                compress = false;
              }
            ];
          }
        ];
      };
    };

    nginx = {
      enable = true;
      virtualHosts = {
        "matrix.cyperpunk.de" = {
          locations."/" = {
            proxyPass = "http://127.0.0.1:${toString (builtins.elemAt config.services.matrix-synapse.settings.listeners 0).port}";
            proxyWebsockets = true;
            extraConfig = ''
              proxy_set_header Host matrix.cyperpunk.de;
            '';
          };
        };
        "cinny" = {
          listen = [
            {
              addr = "0.0.0.0";
              port = 8080;
            }
          ];
          locations."/" = {
            alias = "${pkgs.cinny}/";
            extraConfig = ''
              try_files $uri $uri/ /index.html;
            '';
          };
        };
        "${serverIP}" = {
          locations = {
            "/_matrix/" = {
              proxyPass = "http://127.0.0.1:${toString (builtins.elemAt config.services.matrix-synapse.settings.listeners 0).port}";
              proxyWebsockets = true;
            };
          };
        };
      };
    };
  };
}
