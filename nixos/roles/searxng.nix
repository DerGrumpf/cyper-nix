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
  services.searx = {
    enable = true;
    package = pkgs.searxng;
    redisCreateLocally = true;

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
      };
    };
  };

  networking.firewall.allowedTCPPorts = [ port ];
}
