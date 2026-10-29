{
  imports = [
    ./disko.nix
    ./hardware-configuration.nix
    ./smb.nix
    ../net-config.nix
    ../boot.nix
    ../../services/monitoring
    ../../services/adguard.nix
    ../../services/unifi.nix
    ../../services/searxng.nix
    #    ../../services/filebrowser.nix
    ../../services/jupyterhub.nix
    ../../services/forgejo
    ../../services/vaultwarden
    ../../services/frontpage
    ../../services/octoprint.nix
    ../../services/postgresql-controller.nix
    ../../services/kanidm
    ../../services/ollama.nix
    #    ../../services/hydra
    ../../services/mailserver.nix
    #    ../../services/pumpkin.nix
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
