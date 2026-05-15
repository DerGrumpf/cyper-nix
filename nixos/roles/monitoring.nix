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
in
{
  sops.secrets = {
    grafana_secret_key = {
      owner = "grafana";
      group = "grafana";
    };
    kanidm_grafana_secret = {
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
          ];
        };
      };
      settings = {
        server = {
          domain = "www.cyperpunk.de"; # serverIP; # "grafana.cyperpunk.de";
          http_port = 2342;
          http_addr = "0.0.0.0";
          root_url = "https://www.cyperpunk.de/grafana/";
          serve_from_sub_path = true;
        };
        security = {
          secret_key = "$__file{${config.sops.secrets.grafana_secret_key.path}}";
          allow_embedding = true;
        };
        auth = {
          disable_login_form = false;
          oauth_allow_insecure_email_lookup = true;
        };
        "auth.generic_oauth" = {
          enabled = true;
          name = "Kanidm";
          client_id = "grafana";
          client_secret = "$__file{${config.sops.secrets.kanidm_grafana_secret.path}}";
          scopes = "openid profile email";
          auth_url = "https://auth.cyperpunk.de/ui/oauth2";
          token_url = "https://auth.cyperpunk.de/oauth2/token";
          api_url = "https://auth.cyperpunk.de/oauth2/openid/grafana/userinfo";
          use_pkce = false;
          allow_sign_up = true;
          auto_assign_org = true;
          auto_assign_org_id = 1;
          auto_assign_org_role = "Admin";
          skip_org_role_sync = true;
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
              targets = [ "100.109.10.91:9009" ];
              labels = {
                instance = "cyper-proxy";
                job = "master";
                index = "1";
              };
            }
          ];
        }
        {
          job_name = "postgresql-replica";
          static_configs = [
            {
              targets = [ "localhost:9188" ];
              labels = {
                instance = config.networking.hostName;
              };
            }
          ];
        }
        {
          job_name = "postgresql-proxy";
          static_configs = [
            {
              targets = [ "100.109.10.91:9188" ];
              labels = {
                instance = "cyper-proxy";
              };
            }
          ];
        }
      ]
      ++ (lib.mapAttrsToList mkNodeJob extraNodes);
    };
  };

  networking.firewall.allowedTCPPorts = [
    2342
    9001
    3100
  ];
}
