{
  config,
  lib,
  pkgs,
  ...
}:
{
  sops.secrets."k3s/token" = { };

  environment = {
    systemPackages = with pkgs; [ nerdctl ];

    persistence."/persist".directories = [
      "/var/lib/rancher/k3s"
      "/etc/rancher/k3s"
    ];
  };

  networking.firewall.allowedUDPPorts = [
    8472 # flannel VXLAN
  ];

  services.k3s = {
    enable = true;
    role = "agent";
    tokenFile = config.sops.secrets."k3s/token".path;
    serverAddr = "https://10.10.0.30:6443"; # node-1's wg IP
    extraFlags = toString [
      "--node-ip=${builtins.head (lib.splitString "/" config.net.wgIP)}"
      "--flannel-iface=wg0"
    ];
  };
}
