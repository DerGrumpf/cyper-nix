{
  config,
  pkgs,
  primaryUser,
  ...
}:
let
  port = 8222;
  userScss = builtins.readFile ./user.vaultwarden.scss.hbs;
in
{

  sops = {
    secrets = {
      "services/vaultwarden/admin_token" = {
        owner = "vaultwarden";
        group = "vaultwarden";
      };
      #"kanidm/vaultwarden_secret" = {
      #  owner = "vaultwarden";
      #  group = "kanidm";
      #  mode = "0440";
      #};
    };

    templates."vaultwarden-env" = {
      owner = "vaultwarden";
      group = "vaultwarden";
      content = ''
        ADMIN_TOKEN=${config.sops.placeholder."services/vaultwarden/admin_token"}

      '';

      #SSO_CLIENT_ID=vaultwarden
      #SSO_CLIENT_SECRET=${config.sops.placeholder."kanidm/vaultwarden_secret"}
    };
  };

  environment.persistence."/persist".directories = [
    {
      directory = "/var/lib/vaultwarden";
      user = "vaultwarden";
      group = "vaultwarden";
      mode = "0750";
    }
  ];

  services = {
    vaultwarden = {
      enable = true;
      #package = pkgs.oidcwarden;
      environmentFile = config.sops.templates."vaultwarden-env".path;
      backupDir = "/var/local/vaultwarden/backup";
      config = {
        DOMAIN = "https://vault.cyperpunk.de";
        ROCKET_ADDRESS = "0.0.0.0";
        ROCKET_PORT = port;
        ROCKET_LOG = "critical";
        SIGNUPS_ALLOWED = false;
        WEBSOCKET_ENABLED = true;
        #SSO_ENABLED = true;
        #SSO_ONLY = false;
        #SSO_AUTHORITY = "https://auth.cyperpunk.de/oauth2/openid/vaultwarden";
        #SSO_SCOPES = "openid profile email";
        #SSO_PKCE = false;
      };
    };

    #kanidm.provision = {
    #  groups.vaultwarden_users = {
    #    members = [ primaryUser ];
    #  };

    #  systems.oauth2.vaultwarden = {
    #    allowInsecureClientDisablePkce = true;
    #    displayName = "Vaultwarden";
    #    originUrl = "https://vault.cyperpunk.de/identity/connect/oidc-signin";
    #    originLanding = "https://vault.cyperpunk.de/";
    #    basicSecretFile = config.sops.secrets."kanidm/vaultwarden_secret".path;
    #    preferShortUsername = true;
    #    scopeMaps.vaultwarden_users = [
    #      "openid"
    #      "profile"
    #      "email"
    #    ];
    #  };
    #};
  };

  networking.firewall.allowedTCPPorts = [ port ];

  systemd = {
    services.vaultwarden-backup-rotate = {
      description = "Rotate old Vaultwarden backups";
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${pkgs.findutils}/bin/find /var/lib/vaultwarden/backup -mtime +30 -delete";
      };
    };

    timers.vaultwarden-backup-rotate = {
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnCalendar = "daily";
        Persistent = true;
      };
    };

    tmpfiles.rules = [
      "d /var/lib/vaultwarden/templates 0750 vaultwarden vaultwarden -"
      "d /var/lib/vaultwarden/templates/scss 0750 vaultwarden vaultwarden -"
      "L+ /var/lib/vaultwarden/templates/scss/user.vaultwarden.scss.hbs 0640 vaultwarden vaultwarden - ${pkgs.writeText "user.vaultwarden.scss.hbs" userScss}"
    ];
  };

}
