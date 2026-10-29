{ config, ... }:
{

  imports = [ ./gs-exporter.nix ];

  sops.secrets."network/zyxel_pass" = {
    group = "gs1200-exporter";
    mode = "0440";
  };

  users.groups.gs1200-exporter = { };

  services = {
    gs1200-exporter.instances = {
      zyxel1 = {
        address = "192.168.2.3";
        port = 9934;
        passwordFile = config.sops.secrets."network/zyxel_pass".path;
        group = "gs1200-exporter";
      };
      zyxel2 = {
        address = "192.168.2.4";
        port = 9935;
        passwordFile = config.sops.secrets."network/zyxel_pass".path;
        group = "gs1200-exporter";
      };
    };

    prometheus.scrapeConfigs = [
      {
        job_name = "gs1200-zyxel1";
        static_configs = [ { targets = [ "localhost:9934" ]; } ];
      }
      {
        job_name = "gs1200-zyxel2";
        static_configs = [ { targets = [ "localhost:9935" ]; } ];
      }
    ];
  };
}
