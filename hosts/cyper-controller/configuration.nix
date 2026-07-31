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
    ../../nixos/roles/matrix/postgres-backup.nix
    ../../nixos/roles/kanidm.nix
    ../../nixos/roles/ollama.nix
  ];

  net = {
    wgIP = "10.10.0.2/24";
    ethAddress = "192.168.2.2/24";
  };

  system.stateVersion = "26.05";
}
