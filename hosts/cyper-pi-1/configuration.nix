{ pkgs, ... }:
{
  imports = [
    ./disko.nix
    ./hardware-configuration.nix
    ../net-config.nix

    #    ../../nixos/roles/octoprint.nix
  ];

  boot = {
    kernelPackages = pkgs.linuxPackages;

    loader = {
      grub.enable = false;
      generic-extlinux-compatible.enable = true;
    };
  };

  net = {
    wgIP = "10.10.0.35/24";
    ethAddress = "192.168.2.35/24";
    ethIface = "end0";
  };

  system.stateVersion = "26.05";
}
