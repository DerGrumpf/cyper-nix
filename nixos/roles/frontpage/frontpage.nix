{ config, lib, ... }:

let
  address = config.systemd.network.networks."10-ethernet".networkConfig.Address;
  ip = builtins.elemAt (lib.splitString "/" address) 0;
in
{
  sops.secrets.flame_password = { };
  sops.secrets.flame_calvin_password = { };

  virtualisation = {
    docker.enable = true;
    oci-containers = {
      backend = "docker";
      containers = {
        flame = {
          image = "pawelmalak/flame:latest";
          ports = [ "15005:5005" ];
          volumes = [
            "/var/lib/flame:/app/data"
            "/var/run/docker.sock:/var/run/docker.sock"
          ];
          environmentFiles = [ config.sops.secrets.flame_password.path ];
        };
        flame-calvin = {
          image = "pawelmalak/flame:latest";
          ports = [ "15006:5005" ];
          volumes = [ "/var/lib/flame-calvin:/app/data" ];
          environmentFiles = [ config.sops.secrets.flame_calvin_password.path ];
        };
      };
    };
  };

  networking.firewall.allowedTCPPorts = [
    15005
    15006
  ];

}
