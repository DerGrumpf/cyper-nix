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
    networks."10-venet" = {
      matchConfig.Name = "venet0";
      networkConfig = {
        Address = "178.254.8.35/24";
        DNS = "178.254.16.141 178.254.16.151";
        DHCP = "no";
      };
      routes = [
        { routeConfig.Destination = "0.0.0.0/0"; }
      ];
    };
  };

  system.stateVersion = "26.05";
}
