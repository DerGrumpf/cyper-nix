{
  pkgs,
  primaryUser,
  lib,
  ...
}:
{
  imports = [
    ./settings.nix
    ./homebrew.nix
    ./yabai.nix
    ./wireguard.nix
  ];

  # nix config
  nix = {
    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      max-jobs = "auto"; # Use all CPU cores
      cores = 0; # Use all cores per build
      # disabled due to https://github.com/NixOS/nix/issues/7273
      # auto-optimise-store = true;
      substituters = [
        "https://cache.nixos.org"
        "https://nix-community.cachix.org"
      ];
      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      ];
    };
    enable = true; # using determinate installer

    # Garbage collection
    gc = {
      automatic = true;
      interval = {
        Weekday = 7;
      }; # Run weekly
      options = "--delete-older-than 30d";
    };
  };

  # Disable Docs
  documentation = {
    enable = true;
    doc.enable = false; # Skip large documentation
    man.enable = true; # Keep man pages
    info.enable = false; # Skip info pages
  };

  # Mirrored Network conf
  networking.knownNetworkServices = [
    "Wi-Fi"
    "Ethernet"
  ];

  # homebrew installation manager
  nix-homebrew = {
    user = primaryUser;
    enable = true;
    autoMigrate = true;
  };

  # macOS-specific settings
  programs.fish.enable = true;
  system.primaryUser = primaryUser;
  users.users.${primaryUser} = {
    home = "/Users/${primaryUser}";
    shell = pkgs.fish;
    openssh.authorizedKeys.keyFiles = [ ../secrets/ssh-key ];
  };

  environment = {
    shells = [ pkgs.fish ];
    systemPath = [ "/opt/homebrew/bin" ];
    pathsToLink = [ "/Applications" ];
    etc."hosts".text = lib.mkAfter ''
      10.10.0.1  proxy.cyperpunk.de
      10.10.0.2  controller.cyperpunk.de
      10.10.0.3  mac.cyperpunk.de
      10.10.0.30 node1.cyperpunk.de
      10.10.0.31 node2.cyperpunk.de
      10.10.0.40 desktop.cyperpunk.de
    '';
  };
}
