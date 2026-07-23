{
  imports = [
    ./disko.nix
    ./hardware-configuration.nix
    ../net-config.nix
    ../boot.nix
  ];

  net = {
    wgIP = "10.10.0.31/24";
    ethAddress = "192.168.2.31/24";
  };

  system.stateVersion = "26.05";
}
