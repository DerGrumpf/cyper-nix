{ config, ... }:
{
  services = {
    maubot = {
      enable = true;
      settings = {
        database = "postgresql://maubot@localhost/maubot";
        server = {
          public_url = "matrix.cyperpunk.de";
          #ui_base_path = "/another/base/path";
        };
      };
    };

    nginx.virtualHosts."matrix.cyperpunk.de".locations = {
      "/_matrix/maubot/" = {
        proxyPass = "http://127.0.0.1:${toString config.services.maubot.settings.server.port}";
        proxyWebsockets = true;
      };
    };
  };
}
