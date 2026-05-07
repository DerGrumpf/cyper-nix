{ config, ... }:
{
  services = {
    nginx.virtualHosts."www.cyperpunk.de".locations."/cloak" = {
      proxyPass = "http://localhost:${toString config.services.keycloak.settings.http-port}/cloak/";
    };

    keycloak = {
      enable = true;

      database = {
        type = "postgresql";
        createLocally = true;

        username = "keycloak";
        passwordFile = "/etc/nixos/secrets/keycloak_psql_pass";
      };

      settings = {
        hostname = "cyperpunk.de";
        http-relative-path = "/cloak";
        http-port = 38080;
        proxy = "passthrough";
        http-enabled = true;
      };
    };
  };
}
