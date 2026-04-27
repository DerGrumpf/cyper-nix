_:
let
  upstream = "100.109.179.25";

  # helper: simple reverse proxy, force SSL
  mkProxy = port: {
    forceSSL = true;
    enableACME = true;
    locations."/" = {
      proxyPass = "http://${upstream}:${toString port}";
    };
  };

  # helper: like mkProxy but with websocket support
  mkWsProxy =
    port:
    (mkProxy port)
    // {
      locations."/" = {
        proxyPass = "http://${upstream}:${toString port}";
        proxyWebsockets = true;
      };
    };

  matrixConfig = ''
    client_max_body_size 50M;
    proxy_set_header X-Forwarded-For $remote_addr;
    proxy_set_header X-Forwarded-Proto $scheme;
    proxy_set_header Host $host;
  '';

  wellKnownMatrix = {
    "/.well-known/matrix/client" = {
      extraConfig = ''
        default_type application/json;
        add_header Access-Control-Allow-Origin *;
        return 200 '{"m.homeserver":{"base_url":"https://matrix.cyperpunk.de"},"org.matrix.msc4143.rtc_foci":[{"type":"livekit","livekit_service_url":"https://cyperpunk.de/livekit/jwt"}]}';
      '';
    };
    "/.well-known/matrix/server" = {
      extraConfig = ''
        default_type application/json;
        add_header Access-Control-Allow-Origin *;
        return 200 '{"m.server":"matrix.cyperpunk.de:443"}';
      '';
    };
  };
in
{
  networking.firewall.allowedTCPPorts = [
    80
    443
  ];

  security.acme = {
    acceptTerms = true;
    defaults.email = "phil.keier@hotmail.com"; # Change accordingly
  };

  services.nginx = {
    enable = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;
    recommendedOptimisation = true;
    recommendedGzipSettings = true;

    virtualHosts = {
      "git.cyperpunk.de" = mkProxy 9000;
      "search.cyperpunk.de" = mkProxy 11080;
      "file.cyperpunk.de" = mkProxy 10000;

      "vault.cyperpunk.de" = mkWsProxy 8222;
      "fluffy.cyperpunk.de" = mkWsProxy 8012;

      "www.cyperpunk.de" = {
        forceSSL = true;
        enableACME = true;
        locations = {
          "/" = {
            proxyPass = "http://${upstream}:15005";
            proxyWebsockets = true;
          };
          "/grafana" = {
            proxyPass = "http://${upstream}:2342";
            proxyWebsockets = true;
          };
        };
      };

      "calvin.cyperpunk.de" = mkWsProxy 15006;
      "cinny.cyperpunk.de" = mkWsProxy 8009;
      "element.cyperpunk.de" = mkWsProxy 8010;

      "cyperpunk.de" = {
        forceSSL = true;
        enableACME = true;
        serverAliases = [ "matrix.cyperpunk.de" ];
        http2 = true;
        extraConfig = matrixConfig;
        locations = wellKnownMatrix // {
          "/" = {
            proxyPass = "http://${upstream}:8008";
            proxyWebsockets = true;
          };
          "^~ /livekit/jwt/" = {
            priority = 400;
            proxyPass = "http://127.0.0.1:8080";
          };
          "^~ /livekit/sfu" = {
            priority = 400;
            proxyPass = "http://127.0.0.1:7880";
            proxyWebsockets = true;
          };
        };
      };
    };
  };
}
