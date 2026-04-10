{ pkgs, ... }:
{
  networking.firewall.allowedTCPPorts = [ 8448 ];

  services = {
    matrix-synapse = {
      enable = true;
      settings = {
        server_name = "cyperpunk.de";
        public_baseurl = "http://matrix.cyperpunk.de";
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
            proxyPass = "http://127.0.0.1:8008";
            proxyWebsockets = true;
            extraConfig = ''
              proxy_set_header Host matrix.cyperpunk.de;
            '';
          };
        };
        "cinny.cyperpunk.de" = {
          locations."/" = {
            root = pkgs.cinny;
            tryFiles = "$uri $uri/ /index.html";
          };
        };
      };
    };
  };
}
