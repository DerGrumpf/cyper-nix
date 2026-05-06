_:
let
  upstream = "100.109.179.25";

  mkProxy = port: {
    forceSSL = true;
    enableACME = true;
    locations."/" = {
      proxyPass = "http://${upstream}:${toString port}";
    };
  };

  mkWsProxy =
    port:
    (mkProxy port)
    // {
      locations."/" = {
        proxyPass = "http://${upstream}:${toString port}";
        proxyWebsockets = true;
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
    defaults.email = "phil.keier@hotmail.com";
  };

  services.nginx = {
    enable = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;
    recommendedOptimisation = true;
    recommendedGzipSettings = true;

    virtualHosts = {
      # controller services (proxied to upstream tailscale node)
      "git.cyperpunk.de" = mkProxy 9000;
      "search.cyperpunk.de" = mkProxy 11080;
      "file.cyperpunk.de" = mkProxy 10000;
      "ngx.cyperpunk.de" = mkWsProxy 28101;
      "vault.cyperpunk.de" = mkWsProxy 8222;
      "calvin.cyperpunk.de" = mkWsProxy 15006;

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
    };
  };
}
