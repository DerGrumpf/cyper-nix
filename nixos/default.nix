{
  pkgs,
  inputs,
  primaryUser,
  ...
}:
{
  imports = [
    ./fonts.nix
    ./sops.nix
    ./regreet.nix
    ./plymouth.nix
    ./audio.nix
    ./ssh.nix
    ./locale.nix
    ./tailscale.nix
    ./virt.nix
    ./webcam.nix

    inputs.catppuccin.nixosModules.catppuccin
  ];

  catppuccin = {
    enable = true;
    accent = "sky";
    flavor = "mocha";
    cache.enable = true;

    cursors = {
      enable = true;
      accent = "sapphire";
    };

    fcitx5.enable = false;
    forgejo.enable = false;
    gitea.enable = false;
    sddm.enable = false;
  };

  # nix config
  nix = {
    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      max-jobs = "auto";
      cores = 0;
      http-connections = 4;
      download-buffer-size = 268435456;
      substituters = [
        "https://cache.nixos.org"
        "https://hyprland.cachix.org"
        "https://nix-community.cachix.org"
      ];
      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      ];
    };

    # Garbage collection
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 30d";
    };
  };

  # Disable Docs
  documentation = {
    enable = true;
    doc.enable = false; # Skip large documentation
    man.enable = false; # Keep man pages
    info.enable = false; # Skip info pages
  };

  nixpkgs.config = {
    allowUnfree = true;
  };

  programs = {
    fish.enable = true;
    hyprland = {
      enable = true;
      package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
    };
    steam.enable = true;
    dconf.enable = true;
    appimage = {
      enable = true;
      binfmt = true;
    };
  };

  security = {
    pam.services.swaylock = { };
    polkit.enable = true;
    apparmor.enable = false;
  };

  services.gnome = {
    tinysparql.enable = true;
    localsearch.enable = true;
  };

  users.users.${primaryUser} = {
    home = "/home/${primaryUser}";
    shell = pkgs.fish;
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "video"
      "audio"
      "libvirtd"
    ];
  };
}
