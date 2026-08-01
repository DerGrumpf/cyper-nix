{
  pkgs,
  config,
  primaryUser,
  ...
}:
let
  domain = "auth.cyperpunk.de";
  port = 8444;
  certDir = "/var/lib/kanidm/tls";
in
{
  sops.secrets = {
    "kanidm/idm_admin_password" = {
      owner = "kanidm";
      mode = "0400";
    };
    "kanidm/synapse_secret" = {
      group = "kanidm";
      mode = "0440";
    };
    "kanidm/mastodon_secret" = {
      group = "kanidm";
      mode = "0440";
    };
  };

  environment.persistence."/persist".directories = [
    {
      directory = "/var/lib/kanidm";
      user = "kanidm";
      group = "kanidm";
      mode = "0750";
    }
  ];

  systemd.services.kanidm-selfsigned-cert = {
    description = "Generate self-signed TLS certificate for Kanidm";
    wantedBy = [ "kanidm.service" ];
    before = [ "kanidm.service" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      if [ ! -f ${certDir}/cert.pem ]; then
        mkdir -p ${certDir}
        ${pkgs.openssl}/bin/openssl req -x509 \
          -newkey rsa:4096 \
          -keyout ${certDir}/key.pem \
          -out    ${certDir}/cert.pem \
          -days   3650 \
          -nodes  \
          -subj   "/CN=${domain}"
        chown -R kanidm:kanidm ${certDir}
        chmod 750 ${certDir}
        chmod 640 ${certDir}/cert.pem ${certDir}/key.pem
      fi
    '';
  };

  services.kanidm = {
    package = pkgs.kanidmWithSecretProvisioning_1_10;

    server = {
      enable = true;
      settings = {
        inherit domain;
        origin = "https://${domain}";

        adminbindpath = "/run/kanidmd/sock";

        tls_chain = "${certDir}/cert.pem";
        tls_key = "${certDir}/key.pem";

        bindaddress = "0.0.0.0:${toString port}";

        log_level = "info";

        online_backup = {
          versions = 7;
          path = "/var/lib/kanidm/backups";
          schedule = "00 22 * * *";
        };
      };
    };

    client = {
      enable = true;
      settings.uri = "https://${domain}";
    };

    provision = {
      enable = true;
      instanceUrl = "https://localhost:${toString port}";
      acceptInvalidCerts = true;
      idmAdminPasswordFile = config.sops.secrets."kanidm/idm_admin_password".path;

      persons = {
        ${primaryUser} = {
          displayName = "DerGrumpf";
          mailAddresses = [ "phil.keier@hotmail.com" ];
        };
      };

      groups = {
        mastodon_users.members = [ primaryUser ];
        jupyterhub_users.members = [ primaryUser ];
        forgejo_users.members = [ primaryUser ];
        synapse_users.members = [ primaryUser ];
        grafana_users.members = [ primaryUser ];
        vaultwarden_users.members = [ primaryUser ];
      };

      systems.oauth2 = {
        synapse = {
          displayName = "Matrix Synapse";
          originUrl = "https://matrix.cyperpunk.de/_synapse/client/oidc/callback";
          originLanding = "https://matrix.cyperpunk.de/";
          basicSecretFile = config.sops.secrets."kanidm/synapse_secret".path;
          preferShortUsername = true;
          scopeMaps.synapse_users = [
            "openid"
            "profile"
            "email"
          ];
        };

        mastodon = {
          allowInsecureClientDisablePkce = true;
          displayName = "Mastodon";
          originUrl = "https://mastodon.cyperpunk.de/auth/auth/openid_connect/callback";
          originLanding = "https://mastodon.cyperpunk.de/";
          basicSecretFile = config.sops.secrets."kanidm/mastodon_secret".path;
          preferShortUsername = true;
          scopeMaps.mastodon_users = [
            "openid"
            "profile"
            "email"
          ];
        };
      };
    };
  };

  networking.firewall.allowedTCPPorts = [ port ];
}
