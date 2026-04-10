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
      provision = {
        enable = true;
        datasources.settings = {
          apiVersion = 1;
          datasources = [
            {
              name = "Prometheus";
              type = "prometheus";
              url = "http://127.0.0.1:${toString config.services.prometheus.port}";
              isDefault = true;
            }
            {
              name = "Loki";
              type = "loki";
              url = "http://127.0.0.1:${toString config.services.loki.configuration.server.http_listen_port}";
              isDefault = false;
            }
          ];
        };
      };
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

    # TODO: Computers should register themselves
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

    loki = {
      enable = true;
      configuration = {
        auth_enabled = false;
        server.http_listen_port = 3100;
        ingester = {
          lifecycler = {
            address = "127.0.0.1";
            ring = {
              kvstore.store = "inmemory";
              replication_factor = 1;
            };
          };
          chunk_idle_period = "5m";
          chunk_retain_period = "30s";
        };
        schema_config.configs = [
          {
            from = "2024-01-01";
            store = "tsdb";
            object_store = "filesystem";
            schema = "v13";
            index = {
              prefix = "index_";
              period = "24h";
            };
          }
        ];
        storage_config = {
          tsdb_shipper = {
            active_index_directory = "/var/lib/loki/tsdb-index";
            cache_location = "/var/lib/loki/tsdb-cache";
          };
          filesystem.directory = "/var/lib/loki/chunks";
        };
        limits_config = {
          reject_old_samples = true;
          reject_old_samples_max_age = "168h";
        };
      };
    };
  };

  networking.firewall.allowedTCPPorts = [
    80
    443
    # TODO: Remove
    9001
    3100
  ];

  systemd.tmpfiles.rules = [
    "d /var/loki 0700 loki loki -"
  ];
}
