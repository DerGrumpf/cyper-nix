{
  config,
  pkgs,
  primaryUser,
  ...
}:

{
  sops.secrets.smb_passwd = { };

  users.users.${primaryUser}.extraGroups = [ "sambashare" ];

  services.samba = {
    enable = true;
    openFirewall = true;

    settings = {
      global = {
        "workgroup" = "WORKGROUP";
        "server string" = "%h (Samba)";
        "server role" = "standalone server";
        "security" = "user";
        "map to guest" = "Never";
        "invalid users" = [ "root" ];
        "socket options" = "TCP_NODELAY IPTOS_LOWDELAY";
        "use sendfile" = "yes";
        "log level" = "1";
        "log file" = "/var/log/samba/log.%m";
        "max log size" = "1000";
      };

      storage-internal = {
        "path" = "/storage/internal";
        "comment" = "Internal storage (btrfs)";
        "browseable" = "yes";
        "read only" = "no";
        "valid users" = primaryUser;
        "create mask" = "0664";
        "directory mask" = "0775";
        "force user" = primaryUser;
      };

      storage-fast = {
        "path" = "/storage/fast";
        "comment" = "Fast storage";
        "browseable" = "yes";
        "read only" = "no";
        "valid users" = primaryUser;
        "create mask" = "0664";
        "directory mask" = "0775";
        "force user" = primaryUser;
      };

      storage-backup = {
        "path" = "/storage/backup";
        "comment" = "Backup storage";
        "browseable" = "yes";
        "read only" = "yes";
        "valid users" = primaryUser;
        "force user" = primaryUser;
      };
    };
  };

  systemd.services.samba-set-password = {
    description = "Set Samba password for ${primaryUser}";
    wantedBy = [ "multi-user.target" ];
    after = [
      "smbd.service"
      "sops-nix.service"
    ];
    requires = [ "smbd.service" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = pkgs.writeShellScript "samba-set-password" ''
        PASSWORD=$(cat /run/secrets/smb-password-phil)
        echo -e "$PASSWORD\n$PASSWORD" | ${pkgs.samba}/bin/smbpasswd -a -s ${primaryUser}
      '';
    };
  };
}
