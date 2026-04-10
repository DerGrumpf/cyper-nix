{ config, ... }:
{
  services = {
    grafana = {
      enable = true;
      domain = "grafana.cyperpunk.de";
      port = 2342;
      addr = "127.0.0.1";
    };

    # nginx reverse proxy
    nginx.virtualHosts.${config.services.grafana.domain} = {
      locations."/" = {
        proxyPass = "http://127.0.0.1:${toString config.services.grafana.port}";
        proxyWebsockets = true;
        extraConfig = ''
          proxy_set_header Host ${config.services.grafana.domain};
        '';
      };
    };

    prometheus = {
      enable = true;
      port = 9001;
      scrapeConfigs = [
        {
          job_name = config.networking.hostName;
          static_configs = [
            {
              targets = [
                "${config.networking.primaryIPAddress}:${toString config.services.prometheus.exporters.node.port}"
              ];
            }
          ];
        }
      ];
    };
  };

  networking.firewall.allowedTCPPorts = [ 80 ];
}
