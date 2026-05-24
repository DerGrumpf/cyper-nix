{
  config,
  pkgs,
  ...
}:
let
  port = 8222;
in
{
  sops.secrets.vaultwarden_env = {
    owner = "vaultwarden";
    group = "vaultwarden";
  };
  services.vaultwarden = {
    enable = true;
    package = pkgs.oidcwarden;
    environmentFile = config.sops.secrets.vaultwarden_env.path;
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
  };
}
