{ config, ... }:
{
  services = {
    maubot = {
      enable = true;
      plugins = [ config.services.maubot.package.plugins.weather ];
      settings = {
        database = "postgresql:///maubot?host=/run/postgresql";
        homeservers = {
          "cyperpunk.de" = {
            url = "https://matrix.cyperpunk.de";
          };
        };
        admins = {
          root = "";
          dergrumpf = "$2b$12$62kYoqsSloK3hco/N/EZUupD/JOjTMMVhUf064cqveBJYXGJJF8Hi";
        };
        plugin_directories = {
          upload = "/var/lib/maubot/plugins";
          load = [ "/var/lib/maubot/plugins" ];
          trash = "/var/lib/maubot/trash";
        };
      };
    };

    postgresql = {
      ensureUsers = [
        {
          name = "maubot";
          ensureDBOwnership = true;
        }
      ];
      ensureDatabases = [ "maubot" ];
    };

    nginx.virtualHosts."cyperpunk.de".locations."/_matrix/maubot/" = {
      proxyPass = "http://127.0.0.1:29316";
      proxyWebsockets = true;
    };
  };

  systemd.tmpfiles.rules = [
    "d /var/lib/maubot/plugins 0750 maubot maubot -"
    "d /var/lib/maubot/trash 0750 maubot maubot -"
  ];
}
