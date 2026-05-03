{
  config,
  lib,
  ...
}:
let
  serverIP = builtins.head (
    builtins.match "([0-9.]+)/.*" config.systemd.network.networks."10-ethernet".networkConfig.Address
  );

  nodePort = toString config.services.prometheus.exporters.node.port;

  mkNodeJob = name: ip: {
    job_name = name;
    static_configs = [ { targets = [ "${ip}:${nodePort}" ]; } ];
  };

  extraNodes = {
    "cyper-desktop" = "192.168.2.40";
    "cyper-node-1" = "192.168.2.30";
    "cyper-node-2" = "192.168.2.31";
    "cyper-proxy" = "178.254.8.35";
  };

  mkWeatherScrapeConfigs =
    cities:
    map (city: {
      job_name = "weather_${lib.strings.toLower (lib.strings.replaceStrings [ " " ] [ "_" ] city)}";
      scrape_interval = "5m";
      scrape_timeout = "30s";
      metrics_path = "/${city}";
      params.format = [ "p1" ];
      static_configs = [ { targets = [ "wttr.in" ]; } ];
      scheme = "https";
      metric_relabel_configs = [
        {
          target_label = "location";
          replacement = city;
        }
      ];
    }) cities;

  weatherCities = [
    # Braunschweig itself
    "Braunschweig"

    # Immediate surroundings (~15km)
    "Wolfenbuettel"
    "Salzgitter"
    "Peine"
    "Cremlingen"
    "Wendeburg"
    "Sickte"

    # Greater region (~50km)
    "Wolfsburg"
    "Gifhorn"
    "Goslar"
    "Hildesheim"
    "Hannover"
  ];
in
{
  sops.secrets = {
    grafana_secret_key = {
      owner = "grafana";
      group = "grafana";
    };

  };

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
          domain = "www.cyperpunk.de"; # serverIP; # "grafana.cyperpunk.de";
          http_port = 2342;
          http_addr = "0.0.0.0";
          root_url = "http://www.cyperpunk.de/grafana/";
          serve_from_sub_path = true;
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

    # TODO: Computers should register themselves
    prometheus = {
      enable = true;
      port = 9001;

      scrapeConfigs = [
        (mkNodeJob config.networking.hostName serverIP)
        {
          job_name = "gitea";
          static_configs = [
            {
              targets = [
                "localhost:${toString config.services.gitea.settings.server.HTTP_PORT}"
              ];
            }
          ];
          metrics_path = "/metrics";
        }
        {
          job_name = "synapse";
          scrape_interval = "15s";
          metrics_path = "/_synapse/metrics";
          static_configs = [
            {
              targets = [ "127.0.0.1:9009" ];
              labels = {
                instance = config.networking.hostName;
                job = "master";
                index = "1";
              };
            }
          ];
        }
      ]
      ++ (lib.mapAttrsToList mkNodeJob extraNodes)
      ++ (mkWeatherScrapeConfigs weatherCities);
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
    2342
    9001
    3100
  ];

  systemd.tmpfiles.rules = [
    "d /var/loki 0700 loki loki -"
  ];
}
