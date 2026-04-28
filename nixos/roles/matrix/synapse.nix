{
  config,
  pkgs,
  ...
}:
{

  networking.firewall.allowedTCPPorts = [
    8008 # Matrix Synapse
    8448 # Matrix federation
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
        public_baseurl = "https://matrix.cyperpunk.de";
        enable_registration = false; # TODO: disable
        enable_registration_without_verification = false;
        trusted_key_servers = [ { server_name = "matrix.org"; } ];
        suppress_key_server_warning = true;
        registration_shared_secret_path = config.sops.secrets.matrix_registration_secret.path;
        macaroon_secret_key = "$__file{${config.sops.secrets.matrix_macaroon_secret.path}}";
        experimental_features = {
          "msc3266_enabled" = true;
          "msc3779_enabled" = true;
          "msc3401_enabled" = true;
          "msc4143_enabled" = true;
          "msc4195_enabled" = true;
        };
        listeners = [
          {
            port = 8008;
            bind_addresses = [ "0.0.0.0" ];
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
