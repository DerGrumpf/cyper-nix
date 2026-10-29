{ config, pkgs, ... }:
let
  iface = config.systemd.network.networks."10-ethernet".matchConfig.Name;
in
{

  environment.persistence."/persist".directories = [
    {
      directory = "/var/lib/watchyourlan";
      user = "watchyourlan";
      group = "watchyourlan";
      mode = "0750";
    }
  ];

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
      GUIIP = "0.0.0.0";
      GUIPORT = "8840";
      PROMETHEUS_ENABLE = "true";
    };
  };

  services = {
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
