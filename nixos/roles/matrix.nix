{ config, ... }:
{
  networking.firewall = {
    allowedTCPPorts = [
      8008
      8448
      3478
    ];
    allowedUDPPorts = [
      3478
    ];
    allowedUDPPortRanges = [
      {
        from = 49152;
        to = 65535;
      }
    ];
  };

  sops.secrets = {
    matrix_macaroon_secret = { };
    matrix_registration_secret = {
      owner = "matrix-synapse";
      group = "matrix-synapse";
    };
    matrix_turn_secret = {
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
        enable_registration = true; # TODO: disable
        enable_registration_without_verification = true;
        trusted_key_servers = [ { server_name = "matrix.org"; } ];
        suppress_key_server_warning = true;
        registration_shared_secret_path = config.sops.secrets.matrix_registration_secret.path;
        macaroon_secret_key = "$__file{${config.sops.secrets.matrix_macaroon_secret.path}}";

        # TURN configuration
        turn_uris = [
          "turn:turn.cyperpunk.de?transport=udp"
          "turn:turn.cyperpunk.de?transport=tcp"
        ];
        turn_shared_secret_path = config.sops.secrets.matrix_turn_secret.path;
        turn_user_lifetime = "1h";
        experimental_features = {
          "msc3266_enabled" = true;
        };
        extra_well_known_client_content = {
          "io.element.call.backend" = {
            url = "https://call.element.io";
          };
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
        ];
      };
    };

    coturn = {
      enable = true;
      no-cli = true;
      no-tcp-relay = true;
      min-port = 49152;
      max-port = 65535;
      use-auth-secret = true;
      static-auth-secret-file = config.sops.secrets.matrix_turn_secret.path;
      realm = "turn.cyperpunk.de";
      extraConfig = ''
        no-multicast-peers
      '';
    };
  };
}
