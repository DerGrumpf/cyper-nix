# pumpkin.nix
{ lib, ... }:
{
  services.pumpkin = {
    enable = true;
    openFirewall = true;

    dataDir = "/storage/fast/pumpkin";

    whitelist.entries = [
      {
        name = "Der_Grumpf";
        uuid = "d3dd297f-0c08-45a0-8260-f1ac46af490a";
      }
    ];

    settings = {
      default_difficulty = "Normal";
      default_gamemode = "Survival";
      force_gamemode = false;
      hardcore = false;
      tps = 20.0;

      allow_nether = true;
      allow_end = true;
      scrub_ips = true;
      use_favicon = true;
      default_level_name = "world";
      allow_chat_reports = false;
      seed = "1785537519969227430";

      white_list = false;
      enforce_whitelist = false;

      logging = {
        enabled = true;
        threads = true;
        color = true;
        timestamp = true;
        file = "pumpkin.log";
      };

      world = {
        lighting = "default";
        autosave_ticks = 6000;
        chunk = {
          type = "anvil";
          write_in_place = false;
          compression = {
            algorithm = "LZ4";
            level = 6;
          };
        };
      };

      networking = {
        query = {
          enabled = true;
          address = "0.0.0.0:25565";
        };

        rcon.enabled = false;

        proxy = {
          enabled = false;
          velocity.enabled = false;
          bungeecord.enabled = false;
        };

        lan_broadcast.enabled = false;

        java = {
          enabled = true;
          address = "0.0.0.0:25565";
          compression = {
            enabled = true;
            threshold = 256;
            level = 4;
          };
          authentication = {
            enabled = true;
            connect_timeout = 5000;
            read_timeout = 5000;
            prevent_proxy_connections = false;
          };
        };

        bedrock.enabled = false;
      };

      commands = {
        use_console = true;
        use_tty = true;
        log_console = true;
        broadcast_console_to_ops = true;
        default_op_level = 4;
      };

      chat.format = "<-{DISPLAYNAME}-> |{MESSAGE}|";

      pvp = {
        enabled = true;
        hurt_animation = true;
        protect_creative = true;
        knockback = true;
        swing = true;
      };

      server_links = {
        enabled = true;
        bug_report = "https://github.com/Pumpkin-MC/Pumpkin/issues";
      };

      player_data = {
        save_player_data = true;
        save_player_cron_interval = 300;
      };
    };
  };

  systemd = {
    tmpfiles.rules = [
      "d /storage/fast/pumpkin 0750 pumpkin pumpkin -"
    ];

    services.pumpkin.serviceConfig = {
      DynamicUser = lib.mkForce false;
      User = "pumpkin";
      Group = "pumpkin";
      ReadWritePaths = [ "/storage/fast/pumpkin" ];
    };
  };

  users = {
    users.pumpkin = {
      isSystemUser = true;
      group = "pumpkin";
    };
    groups.pumpkin = { };
  };
}
