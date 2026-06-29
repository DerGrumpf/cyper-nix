{
  pkgs,
  inputs,
  lib,
  config,
  primaryUser,
  isServer,
  ...
}:
{
  imports = [
    ./sops.nix
    ./locale.nix
    ./wireguard.nix
    ./ssh.nix
    ./impermanence.nix
  ]
  ++ lib.optionals (!isServer) [
    ./regreet.nix
    ./plymouth.nix
    ./audio.nix
    ./virt.nix
    ./catppuccin.nix
  ];

  sops.secrets."nix_cache_priv_key" = {

    mode = "0400";
  };

  nix = {
    settings = {
      trusted-users = [
        "root"
        primaryUser
      ];
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
        "https://cyper-cache.cachix.org"
      ];
      secret-key-files = [ config.sops.secrets."nix_cache_priv_key".path ];
      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "cyper-cache.cachix.org-1:pOpeWFEjGHg9XvqRg+DQpYnGRQNp+z+QEF8Ev2mbSoM="
        "cyper-nix:+YuG586UwrtNkXeGiivcr5GTCbZK70ILU2YqOxUoIWw="
      ];
      auto-optimise-store = true;
    };
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 30d";
    };
  };

  nixpkgs.config = {
    allowUnfree = true;
    permittedInsecurePackages = [ "olm-3.2.16" ];
  };

  documentation = {
    enable = true;
    doc.enable = false;
    man.enable = false;
    info.enable = false;
  };

  programs = {
    fish.enable = true;
  }
  // lib.optionalAttrs (!isServer) {
    dconf.enable = true;
    steam.enable = true;
    appimage = {
      enable = true;
      binfmt = true;
    };
    hyprland = {
      enable = true;
      package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
    };
  };

  environment.systemPackages = with pkgs; [ git ];

  security = lib.mkIf (!isServer) {
    pam.services.swaylock = { };
    polkit.enable = true;
    apparmor.enable = false;
  };

  services = {
    prometheus.exporters.node = {
      enable = true;
      port = 9002;
    };

    gnome = lib.mkIf (!isServer) {
      tinysparql.enable = true;
      localsearch.enable = true;
    };
  };

  sops.secrets.cachix_auth_token = { };

  systemd.services.cachix-push = {
    description = "Push new store paths to Cachix";
    after = [ "multi-user.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = "${pkgs.bash}/bin/bash -c 'CACHIX_AUTH_TOKEN=$(cat ${config.sops.secrets.cachix_auth_token.path}) ${pkgs.nix}/bin/nix path-info --recursive /run/current-system | CACHIX_AUTH_TOKEN=$(cat ${config.sops.secrets.cachix_auth_token.path}) ${pkgs.cachix}/bin/cachix push cyper-cache'";
    };
  };

  networking.firewall.allowedTCPPorts = [
    9002
    3100
  ];

  users.users.${primaryUser} = {
    home = "/home/${primaryUser}";
    shell = pkgs.fish;
    isNormalUser = true;
    extraGroups = [
      "wheel"
    ]
    ++ lib.optionals (!isServer) [
      "video"
      "audio"
      "libvirtd"
      "input"
    ];
  };
}
