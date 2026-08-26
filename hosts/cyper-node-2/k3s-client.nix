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
