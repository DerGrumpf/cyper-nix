{ modulesPath, pkgs, ... }:
{
  imports = [ (modulesPath + "/installer/sd-card/sd-image-aarch64.nix") ];

  time.timeZone = "Europe/Berlin";

  boot.zfs.forceImportRoot = false;

  services.openssh = {
    enable = true;
    openFirewall = true;
    settings = {
      PermitRootLogin = "yes";
      PasswordAuthentication = false;
    };
  };

  users.users.root.openssh.authorizedKeys.keyFiles = [
    ../../secrets/ssh-key
  ];

  networking = {
    useDHCP = true;
    firewall.enable = false;
  };

  environment.systemPackages = with pkgs; [
    htop
    usbutils
  ];

  system.stateVersion = "26.05";
}
