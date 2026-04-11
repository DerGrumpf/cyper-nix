{ config, pkgs, ... }:

let
  address = config.systemd.network.networks."10-ethernet".networkConfig.Address;
  ip = builtins.head (builtins.splitVersion address); # strips the /24
  port = 8222;
in
{
  services.vaultwarden = {
    enable = true;
    environmentFile = config.sops.templates.vaultwarden_env.path;
    backupDir = "/var/lib/vaultwarden/backup";

    config = {
      DOMAIN = "http://${ip}:${toString port}";
      ROCKET_ADDRESS = "0.0.0.0";
      ROCKET_PORT = port;
      ROCKET_LOG = "critical";
      SIGNUPS_ALLOWED = false;
      WEBSOCKET_ENABLED = true;
    };
  };

  networking.firewall.allowedTCPPorts = [ port ];

  systemd.services.vaultwarden-backup-rotate = {
    description = "Rotate old Vaultwarden backups";
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.findutils}/bin/find /var/lib/vaultwarden/backup -mtime +30 -delete";
    };
  };

  systemd.timers.vaultwarden-backup-rotate = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "daily";
      Persistent = true;
    };
  };
}
