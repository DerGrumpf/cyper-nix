{ config, lib, ... }:
{
  sops.secrets."k3s/token" = { };

  environment.persistence."/persist".directories = [
    "/var/lib/rancher/k3s"
    "/etc/rancher/k3s"
  ];

  networking.firewall = {
    allowedTCPPorts = [
      6443 # k3s API server
      2379 # etcd (harmless if unused)
      2380
    ];
    allowedUDPPorts = [
      8472 # flannel VXLAN
    ];
  };

  services.k3s = {
    enable = true;
    role = "server";
    tokenFile = config.sops.secrets."k3s/token".path;
    extraFlags = toString [
      "--node-ip=${builtins.head (lib.splitString "/" config.net.wgIP)}"
      "--flannel-iface=wg0"
      "--bind-address=${builtins.head (lib.splitString "/" config.net.wgIP)}"
      "--advertise-address=${builtins.head (lib.splitString "/" config.net.wgIP)}"
      #      "--disable=traefik"
    ];
  };
}
