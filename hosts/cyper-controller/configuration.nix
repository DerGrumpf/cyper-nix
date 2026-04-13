{
  imports = [
    ./hardware-configuration.nix
    ../../nixos/roles/monitoring.nix
    ../../nixos/roles/matrix.nix
    ../../nixos/roles/postgresql.nix
    ../../nixos/roles/wyl.nix
    ../../nixos/roles/adguard.nix
    ../../nixos/roles/unifi.nix
    ../../nixos/roles/searxng.nix
    ../../nixos/roles/filebrowser.nix
    ../../nixos/roles/gitea.nix
    ../../nixos/roles/vaultwarden.nix
    ../../nixos/roles/frontpage
    ../../nixos/roles/cage.nix
  ];

  networking = {
    useNetworkd = true;
    useDHCP = false;
    firewall.enable = true;
  };

  systemd.network = {
    enable = true;
    networks."10-ethernet" = {
      matchConfig.Name = "enp1s0";
      networkConfig = {
        Address = "192.168.2.2/24";
        Gateway = "192.168.2.1";
        DNS = "192.168.2.2";
        DHCP = "no";
      };
    };
  };

  boot.loader = {
    systemd-boot = {
      enable = true;
      configurationLimit = 10;
      editor = false;
    };
    efi.canTouchEfiVariables = true;
  };

  system.stateVersion = "26.05";
}
