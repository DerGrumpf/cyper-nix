{
  imports = [
    ./disko.nix
    ./hardware-configuration.nix
  ];

  networking = {
    useNetworkd = true;
    useDHCP = false;
    firewall.enable = true;
    wireguard.interfaces.wg0 = {
      ips = [ "10.10.0.31/24" ];
      peers = [
        {
          publicKey = "NjMYaUZO/iPRM/J46qyPPuWYg5oSeAUxjocMs/hYTXs=";
          endpoint = "178.254.8.35:51820";
          allowedIPs = [ "10.10.0.0/24" ];
          persistentKeepalive = 25;
        }
      ];
    };
  };

  systemd.network = {
    enable = true;
    networks."10-ethernet" = {
      matchConfig.Name = "enp1s0";
      networkConfig = {
        Address = "192.168.2.31/24";
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
