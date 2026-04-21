{ ... }:

{
  networking.firewall.allowedTCPPorts = [
    80
    443
  ];

  security.acme = {
    acceptTerms = true;
    defaults.email = "your@email.de";
  };

  services.nginx = {
    enable = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;
    recommendedOptimisation = true;
    recommendedGzipSettings = true;

    virtualHosts = {
      "git.cyperpunk.de" = {
        forceSSL = true;
        enableACME = true;
        locations."/" = {
          proxyPass = "http://100.109.179.25:9000";
        };
      };

      "www.cyperpunk.de" = {
        enableACME = true;
        locations = {
          "/" = {
            proxyPass = "http://100.109.179.25:15005";
            proxyWebsockets = true;
          };
          "/grafana" = {
            proxyPass = "http://100.109.179.25:2342";
            proxyWebsockets = true;
          };
        };
      };

      "search.cyperpunk.de" = {
        forceSSL = true;
        enableACME = true;
        locations."/" = {
          proxyPass = "http://100.109.179.25:11080";
        };
      };

      "vault.cyperpunk.de" = {
        forceSSL = true;
        enableACME = true;
        locations."/" = {
          proxyPass = "http://100.109.179.25:8222";
          proxyWebsockets = true;
        };
      };

      "file.cyperpunk.de" = {
        forceSSL = true;
        enableACME = true;
        locations."/" = {
          proxyPass = "http://100.109.179.25:10000";
        };
      };

      "calvin.cyperpunk.de" = {
        enableACME = true;
        locations."/" = {
          proxyPass = "http://100.109.179.25:15006";
        };
      };

      "cyperpunk.de" = {
        forceSSL = true;
        enableACME = true;
        http2 = true;
        extraConfig = ''
          client_max_body_size 50m;
        '';
        locations."/" = {
          proxyPass = "http://100.109.179.25:8008";
          proxyWebsockets = true;
        };
      };

      "matrix.cyperpunk.de" = {
        forceSSL = true;
        enableACME = true;
        http2 = true;
        extraConfig = ''
          client_max_body_size 50m;
        '';
        locations."/" = {
          proxyPass = "http://100.109.179.25:8008";
          proxyWebsockets = true;
        };
      };

      "cinny.cyperpunk.de" = {
        enableACME = true;
        locations."/" = {
          proxyPass = "http://100.109.179.25:8009";
          proxyWebsockets = true;
        };
      };

      "element.cyperpunk.de" = {
        enableACME = true;
        locations."/" = {
          proxyPass = "http://100.109.179.25:8010";
          proxyWebsockets = true;
        };
      };

      "fluffy.cyperpunk.de" = {
        forceSSL = true;
        enableACME = true;
        locations."/" = {
          proxyPass = "http://100.109.179.25:8012";
          proxyWebsockets = true;
        };
      };

      "livekit.cyperpunk.de" = {
        enableACME = true;
        locations = {
          "/" = {
            proxyPass = "http://192.168.64.1:7880";
            proxyWebsockets = true;
          };
          "/_matrix/livekit/jwt" = {
            proxyPass = "http://192.168.64.1:8080";
            proxyWebsockets = true;
          };
        };
      };
    };
  };
}
