{
  config,
  pkgs,
  ...
}:
let
  port = 8222;
  userScss = builtins.readFile ./user.vaultwarden.scss.hbs;
in
{

  sops.secrets."services/vaultwarden/env" = {
    owner = "vaultwarden";
    group = "vaultwarden";
  };

  environment.persistence."/persist".directories = [
    {
      directory = "/var/lib/vaultwarden";
      user = "vaultwarden";
      group = "vaultwarden";
      mode = "0750";
    }
  ];

  services.vaultwarden = {
    enable = true;
    package = pkgs.oidcwarden;
    environmentFile = config.sops.secrets."services/vaultwarden/env".path;
    backupDir = "/var/local/vaultwarden/backup";
    config = {
      DOMAIN = "https://vault.cyperpunk.de";
      ROCKET_ADDRESS = "0.0.0.0";
      ROCKET_PORT = port;
      ROCKET_LOG = "critical";
      SIGNUPS_ALLOWED = false;
      WEBSOCKET_ENABLED = true;
      SSO_ENABLED = true;
      SSO_ONLY = false;
      SSO_AUTHORITY = "https://auth.cyperpunk.de/oauth2/openid/vaultwarden";
      SSO_SCOPES = "openid profile email";
      SSO_PKCE = false;
    };
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
