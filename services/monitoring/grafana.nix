{
  config,
  pkgs,
  primaryUser,
  ...
}:
{
  sops.secrets = {
    "services/grafana/secret_key" = {
      owner = "grafana";
      group = "grafana";
    };
    "services/grafana/xonotic_automod" = {
      owner = "grafana";
      group = "grafana";
    };
    "kanidm/grafana_secret" = {
      owner = "grafana";
      group = "kanidm";
      mode = "0440";
    };
    "services/grafana/smtp_password" = {
      owner = "grafana";
      group = "grafana";
    };
  };

  environment.persistence."/persist".directories = [
    {
      directory = "/var/lib/grafana";
      user = "grafana";
      group = "grafana";
      mode = "0750";
    }
  ];

  services = {
    prometheus = {
      enable = true;
      port = 9001;
    };

    grafana = {
      enable = true;

      declarativePlugins = [
        (pkgs.grafanaPlugins.yesoreyeram-infinity-datasource.overrideAttrs (old: {
          src = pkgs.fetchurl {
            name = "yesoreyeram-infinity-datasource-4.1.0.zip";
            inherit (old.src) url;
            hash = "sha256-E3CBS3xVqdBJq4ylHaFmX75INZjI0fk6RX4yYNL1IhI=";
          };
        }))

        pkgs.grafanaPlugins.prometheus
      ];

      provision = {
        enable = true;

        datasources.settings = {
          apiVersion = 1;
          datasources = [
            {
              name = "Prometheus";
              type = "prometheus";
              uid = "prometheus";
              url = "http://127.0.0.1:${toString config.services.prometheus.port}";
              isDefault = true;
            }
            {
              name = "AutoMod";
              type = "yesoreyeram-infinity-datasource";
              uid = "automod";
              jsonData = {
                httpHeaderName1 = "X-API-Key";
                allowedHosts = [ "http://10.10.0.100:8090" ];
              };
              secureJsonData = {
                httpHeaderValue1 = "$__file{${config.sops.secrets."services/grafana/xonotic_automod".path}}";
              };
            }
          ];
        };

        dashboards.settings = {
          apiVersion = 1;
          providers = [
            {
              name = "default";
              options = {
                path = ./dashboards;
                foldersFromFilesStructure = true;
              };
            }
          ];
        };
      };

      settings = {
        server = {
          domain = "[www.cyperpunk.de](https://www.cyperpunk.de)";
          http_port = 2342;
          http_addr = "0.0.0.0";
          root_url = "https://www.cyperpunk.de/grafana/";
          serve_from_sub_path = true;
        };

        smtp = {
          enabled = true;
          host = "mail.cyperpunk.de:587";
          user = "grafana@cyperpunk.de";
          password = "$__file{${config.sops.secrets."services/grafana/smtp_password".path}}";
          from_address = "grafana@cyperpunk.de";
          from_name = "Grafana";
          starttls_policy = "MandatoryStartTLS";
        };

        security = {
          secret_key = "$__file{${config.sops.secrets."services/grafana/secret_key".path}}";
          allow_embedding = true;
          cookie_samesite = "none";
          cookie_secure = true;
        };

        auth = {
          disable_login_form = false;
          oauth_allow_insecure_email_lookup = true;
        };

        "auth.generic_oauth" = {
          enabled = true;
          name = "Kanidm";
          client_id = "grafana";
          client_secret = "$__file{${config.sops.secrets."kanidm/grafana_secret".path}}";
          scopes = "openid profile email groups";
          auth_url = "https://auth.cyperpunk.de/ui/oauth2";
          token_url = "https://auth.cyperpunk.de/oauth2/token";
          api_url = "https://auth.cyperpunk.de/oauth2/openid/grafana/userinfo";
          use_pkce = false;
          allow_sign_up = true;
          auto_assign_org = true;
          auto_assign_org_id = 1;
          role_attribute_path = "contains(groups[*], 'grafana_admins') && 'Admin' || 'Editor'";
          skip_org_role_sync = true;
        };

        "auth.anonymous" = {
          enabled = true;
          org_role = "Viewer";
        };
      };
    };

    kanidm.provision = {
      groups = {
        grafana_users = {
          members = [ primaryUser ];
        };
        grafana_admins = {
          members = [ primaryUser ];
        };
      };

      systems.oauth2.grafana = {
        allowInsecureClientDisablePkce = true;
        displayName = "Grafana";
        originUrl = "https://www.cyperpunk.de/grafana/login/generic_oauth";
        originLanding = "https://www.cyperpunk.de/grafana/";
        basicSecretFile = config.sops.secrets."kanidm/grafana_secret".path;
        preferShortUsername = true;
        scopeMaps.grafana_users = [
          "openid"
          "profile"
          "email"
          "groups"
        ];
        supplementaryScopeMaps.grafana_admins = [
          "groups"
        ];
      };
    };
  };

  networking.firewall.allowedTCPPorts = [
    2342
    9001
  ];
}
