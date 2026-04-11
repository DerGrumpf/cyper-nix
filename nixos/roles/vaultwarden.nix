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
      DOMAIN = "http://${ip}:${toString port}";
      ROCKET_ADDRESS = "0.0.0.0";
      ROCKET_PORT = port;
      ROCKET_LOG = "critical";
      SIGNUPS_ALLOWED = true;
      WEBSOCKET_ENABLED = true;
      ROCKET_TLS = "{certs=\"/var/lib/vaultwarden/ssl/cert.pem\",key=\"/var/lib/vaultwarden/ssl/key.pem\"}";
    };
  };

  sops.secrets.vaultwarden_admin_token = {
    owner = "vaultwarden";
    group = "vaultwarden";
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

  # TODO: Remove for proper TLS Setup
  systemd.services.vaultwarden-gen-cert = {
    description = "Generate self-signed cert for Vaultwarden";
    before = [ "vaultwarden.service" ];
    wantedBy = [ "vaultwarden.service" ];
    serviceConfig.Type = "oneshot";
    script = ''
      mkdir -p /var/lib/vaultwarden/ssl
      if [ ! -f /var/lib/vaultwarden/ssl/cert.pem ]; then
        ${pkgs.openssl}/bin/openssl req -x509 -newkey rsa:4096 -nodes \
          -keyout /var/lib/vaultwarden/ssl/key.pem \
          -out /var/lib/vaultwarden/ssl/cert.pem \
          -days 3650 \
          -subj "/CN=${ip}" \
          -addext "subjectAltName=IP:${ip}"
        chown -R vaultwarden:vaultwarden /var/lib/vaultwarden/ssl
      fi
    '';
  };
}
