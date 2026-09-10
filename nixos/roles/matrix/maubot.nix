{ config, pkgs, ... }:
{
  environment = {
    systemPackages = with pkgs; [
      maubot
    ];
    persistence."/persist".directories = [
      {
        directory = "/var/lib/maubot";
        user = "maubot";
        group = "maubot";
        mode = "0750";
      }
    ];
  };

  sops = {
    secrets."postgres/maubot" = {
      owner = "maubot";
      group = "maubot";
    };

    templates."maubot-extra-config" = {
      owner = "maubot";
      group = "maubot";
      content = ''
        database: postgresql://maubot:${config.sops.placeholder."postgres/maubot"}@10.10.0.2:5432/maubot
      '';
    };
  };

  services = {
    maubot = {
      enable = true;
      extraConfigFile = config.sops.templates."maubot-extra-config".path;
      plugins = with config.services.maubot.package.plugins; [
        weather
        rss
        reminder
        urban
        wolframalpha
        dice
      ];
      settings = {
        database = "postgresql://maubot@10.10.0.2:5432/maubot";
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
