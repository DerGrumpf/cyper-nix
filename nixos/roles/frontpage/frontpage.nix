{ config, lib, ... }:
let
  mkFlameInstance =
    {
      name,
      port,
      extraVolumes ? [ ],
    }:
    lib.nameValuePair name {
      image = "pawelmalak/flame:2.4.0";
      ports = [ "${toString port}:5005" ];
      volumes = [
        "/var/lib/flame-${name}:/app/data"
      ]
      ++ extraVolumes;
      environmentFiles = [ config.sops.secrets."flame_${name}_password".path ];
    };

  instances = [
    {
      name = "phil";
      port = 15005;
      extraVolumes = [ "/var/run/docker.sock:/var/run/docker.sock" ];
    }
    {
      name = "calvin";
      port = 15006;
    }
  ];
in
{
  environment.persistence."/persist".directories = [
    {
      directory = "/var/lib/flame-phil";
      user = "root";
      group = "root";
      mode = "0755";
    }
    {
      directory = "/var/lib/flame-calvin";
      user = "root";
      group = "root";
      mode = "0755";
    }
    {
      directory = "/var/lib/docker";
      user = "root";
      group = "root";
      mode = "0710";
    }
    {
      directory = "/var/lib/private";
      user = "root";
      group = "root";
      mode = "0700";
    }
  ];

  sops.secrets = lib.listToAttrs (
    map ({ name, ... }: lib.nameValuePair "flame_${name}_password" { }) instances
  );

  virtualisation = {
    docker.enable = true;
    oci-containers = {
      backend = "docker";
      containers = lib.listToAttrs (map mkFlameInstance instances);
    };
  };

  networking.firewall.allowedTCPPorts = map ({ port, ... }: port) instances;
}
