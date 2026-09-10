{
  imports = [
    ./disko.nix
    ./hardware-configuration.nix
    ./smb.nix
    ../net-config.nix
    ../boot.nix
    ../../nixos/roles/monitoring.nix
    ../../nixos/roles/wyl.nix
    ../../nixos/roles/adguard.nix
    ../../nixos/roles/unifi.nix
    ../../nixos/roles/searxng.nix
    ../../nixos/roles/filebrowser.nix
    ../../nixos/roles/jupyterhub.nix
    ../../nixos/roles/forgejo.nix
    ../../nixos/roles/vaultwarden.nix
    ../../nixos/roles/frontpage
    ../../nixos/roles/octoprint.nix
    ../../nixos/roles/postgresql-controller.nix
    ../../nixos/roles/kanidm.nix
    ../../nixos/roles/ollama.nix
    #    ../../nixos/roles/hydra.nix
    ../../nixos/roles/mailserver.nix
  ];

  net = {
    wgIP = "10.10.0.2/24";
    ethAddress = "192.168.2.2/24";
  };

  networking = {
    nameservers = [ "127.0.0.1" ];
    resolvconf.useLocalResolver = true;
    firewall.allowedTCPPorts = [
      6080
    ];
  };

  virtualisation.docker.daemon.settings = {
    insecure-registries = [
      "localhost:9000"
      "10.10.0.2:9000"
    ];
    dns = [
      "192.168.2.2"
    ];
  };

  boot.binfmt.emulatedSystems = [
    "aarch64-linux"
    "riscv64-linux"
  ];

  system.stateVersion = "26.05";
}
