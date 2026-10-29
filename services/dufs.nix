{
  primaryUser,
  pkgs,
  config,
  ...
}:
let
  uploadUser = "uploader";
  uploadDir = "/persist/uploads";
  port = 5000;
in
{
  sops.secrets."services/dufs" = { };

  users = {
    users = {
      ${primaryUser}.extraGroups = [ "docker" ];
      dufs = {
        isSystemUser = true;
        group = "dufs";
      };
    };

    groups.dufs = { };
  };

  systemd = {
    tmpfiles.rules = [ "d ${uploadDir} 0750 dufs dufs -" ];
    services.dufs = {
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        User = "dufs";
        LoadCredential = "dufs-pass:${config.sops.secrets."services/dufs".path}";
        ExecStart = pkgs.writeShellScript "dufs-start" ''
          		exec ${pkgs.dufs}/bin/dufs ${uploadDir} --port ${toString port} --allow-upload -a "${uploadUser}:$(cat "$CREDENTIALS_DIRECTORY/dufs-pass")@/:rw"
          		'';
        Restart = "on-failure";
      };
    };
  };

  networking.firewall.allowedTCPPorts = [ port ];
}
