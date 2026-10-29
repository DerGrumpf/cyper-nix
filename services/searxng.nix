{
  config,
  pkgs,
  lib,
  ...
}:

let
  address = config.systemd.network.networks."10-ethernet".networkConfig.Address;
  ip = builtins.elemAt (lib.splitString "/" address) 0;
  port = 11080;
in
{
  boot.kernel.sysctl."vm.overcommit_memory" = lib.mkForce "1";

  services.searx = {
    enable = true;
    package = pkgs.searxng;
    redisCreateLocally = true;

    limiterSettings = {
      botdetection = {
        ipv4_prefix = 32;
        ipv6_prefix = 56;

        ip_lists.pass_ip = [
          "127.0.0.0/8"
          "::1"
          "10.10.0.0/24"
        ];
      };
    };

    settings = {
      general = {
        instance_name = "SearXNG";
        debug = false;
      };

      server = {
        inherit port;
        bind_address = "0.0.0.0";
        base_url = "http://${ip}:${toString port}";
        secret_key = "@SEARX_SECRET_KEY@";
        limiter = true;
      };

      ui = {
        default_theme = "simple";
        default_locale = "en";
        center_alignment = true;
        infinite_scroll = true;
        theme_args.simple_style = "dark";
      };

      search = {
        safe_search = 0;
        autocomplete = "duckduckgo";
        formats = [
          "html"
          "json"
          "csv"
          "rss"
        ];
      };
    };
  };

  networking.firewall.allowedTCPPorts = [ port ];
}
