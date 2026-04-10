{ config, ... }:
let
  serverIP = builtins.head (
    builtins.match "([0-9.]+)/.*" config.systemd.network.networks."10-ethernet".networkConfig.Address
  );
in
{
  services = {
    grafana = {
      enable = true;
      settings = {
        server = {
          domain = serverIP; # "grafana.cyperpunk.de";
          http_port = 2342;
          http_addr = "127.0.0.1";
          serve_from_sub_path = false;
        };
        security = {
          secret_key = "$__file{${config.sops.secrets.grafana_secret_key.path}}";
          allow_embedding = true;
        };
        auth = {
          disable_login_form = false;
        };
      };
    };

    # nginx reverse proxy
    nginx = {
      enable = true;
      virtualHosts.${config.services.grafana.settings.server.domain} = {
        locations."/" = {
          proxyPass = "http://127.0.0.1:${toString config.services.grafana.settings.server.http_port}";
          proxyWebsockets = true;
          extraConfig = ''
            proxy_set_header Host ${config.services.grafana.settings.server.domain};
          '';
        };
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
              targets = [ "${serverIP}:${toString config.services.prometheus.exporters.node.port}" ];
            }
          ];
        }
        {
          job_name = "cyper-desktop";
          static_configs = [
            {
              targets = [ "192.168.2.40:${toString config.services.prometheus.exporters.node.port}" ];
            }
          ];
        }
      ];
    };
  };

  networking.firewall.allowedTCPPorts = [
    80
    9001
  ];
}
