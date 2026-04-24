{
  imports = [
    ./hardware-configuration.nix
    ../../nixos/roles/nginx.nix
  ];

  networking = {
    hostName = "cyper-proxy";
    useNetworkd = true;
    useDHCP = false;
    firewall.enable = true;
  };

  systemd.network = {
    enable = true;
    networks."10-eth" = {
      matchConfig.Name = "en* eth*"; # catches both naming schemes
      networkConfig.DHCP = "yes";
    };
  };

  system.stateVersion = "26.05";
}
