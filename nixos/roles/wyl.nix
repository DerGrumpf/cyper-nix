{ config, pkgs, ... }:
let
  serverIP = builtins.head (
    builtins.match "([0-9.]+)/.*" config.systemd.network.networks."10-ethernet".networkConfig.Address
  );
  iface = config.systemd.network.networks."10-ethernet".matchConfig.Name;
in
{
  networking.firewall.allowedTCPPorts = [ 8840 ];

  systemd.services.watchyourlan = {
    description = "WatchYourLAN network scanner";
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" ];
    serviceConfig = {
      ExecStart = "${pkgs.watchyourlan}/bin/WatchYourLAN";
      Restart = "always";
      StateDirectory = "watchyourlan";
      WorkingDirectory = "/var/lib/watchyourlan";
      AmbientCapabilities = [ "CAP_NET_RAW" ];
    };
    environment = {
      IFACES = iface;
      GUIIP = "127.0.0.1";
      GUIPORT = "8840";
      PROMETHEUS = "true";
    };
  };

  services = {
    nginx = {
      enable = true;
      virtualHosts."${serverIP}".locations."/wyl/" = {
        proxyPass = "http://127.0.0.1:8840/";
        proxyWebsockets = true;
      };
    };
    prometheus.scrapeConfigs = [
      {
        job_name = "watchyourlan";
        static_configs = [
          {
            targets = [ "127.0.0.1:8840" ];
          }
        ];
      }
    ];
  };
}
