{
  config,
  pkgs,
  lib,
  ...
}:

let
  address = config.systemd.network.networks."10-ethernet".networkConfig.Address;
  ip = builtins.elemAt (lib.splitString "/" address) 0;
  port = 8222;
in
{
  services.vaultwarden = {
    enable = true;
    environmentFile = config.sops.secrets.vaultwarden_admin_token.path;
    backupDir = "/var/local/vaultwarden/backup";

    config = {
      DOMAIN = "https://vault.cyperpunk.de"; # "http://${ip}:${toString port}";
      ROCKET_ADDRESS = "0.0.0.0";
      ROCKET_PORT = port;
      ROCKET_LOG = "critical";
      SIGNUPS_ALLOWED = true;
      WEBSOCKET_ENABLED = true;
    };
  };

  sops.secrets.vaultwarden_admin_token = {
    owner = "vaultwarden";
    group = "vaultwarden";
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
