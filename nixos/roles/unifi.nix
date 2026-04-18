{ pkgs, ... }:

{
  nixpkgs.config.allowUnfree = true;

  services.unifi = {
    enable = true;
    unifiPackage = pkgs.unifi;
    mongodbPackage = pkgs.mongodb-7_0;
    openFirewall = true; # opens 3478/udp, 10001/udp, 8080, 8443, 8843, 8880, 6789
  };
}
