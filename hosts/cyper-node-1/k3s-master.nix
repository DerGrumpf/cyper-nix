{
  config,
  lib,
  pkgs,
  ...
}:
{
  sops.secrets."k3s/token" = { };

  environment = {
    systemPackages = with pkgs; [
      nerdctl
      buildkit
    ];

    persistence."/persist".directories = [
      "/var/lib/rancher/k3s"
      "/etc/rancher/k3s"
    ];
  };

  systemd.services.buildkitd = {
    description = "BuildKit daemon";
    wantedBy = [ "multi-user.target" ];
    after = [ "k3s.service" ];
    serviceConfig = {
      ExecStart = "${pkgs.buildkit}/bin/buildkitd --containerd-worker=true --containerd-worker-addr=/run/k3s/containerd/containerd.sock --containerd-worker-namespace=k8s.io";
      Restart = "always";
    };
  };

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
