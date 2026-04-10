{
  pkgs,
  inputs,
  lib,
  primaryUser,
  isServer,
  ...
}:
{
  imports = [
    ./fonts.nix
    ./sops.nix
    ./locale.nix
    ./tailscale.nix
    ./ssh.nix
  ]
  ++ lib.optionals (!isServer) [
    ./regreet.nix
    ./plymouth.nix
    ./audio.nix
    ./webcam.nix
    ./virt.nix
    ./catppuccin.nix
  ];

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
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 30d";
    };
  };

  documentation = {
    enable = true;
    doc.enable = false;
    man.enable = false;
    info.enable = false;
  };

  nixpkgs.config.allowUnfree = true;

  programs = {
    fish.enable = true;
  }
  // lib.optionalAttrs (!isServer) {
    dconf.enable = true;
    hyprland = {
      enable = true;
      package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
    };
    steam.enable = true;
    appimage = {
      enable = true;
      binfmt = true;
    };
  };

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

    alloy = {
      enable = true;
      extraFlags = [ "--stability.level=public-preview" ];
      configPath = pkgs.writeText "config.alloy" ''
        loki.write "default" {
          endpoint {
            url = "http://192.168.2.30:3100/loki/api/v1/push"
          }
        }

        loki.source.journal "journal" {
          forward_to = [loki.write.default.receiver]
          labels = {
            job  = "systemd-journal",
            host = sys.env("HOSTNAME"),
          }
        }
      '';
    };

    gnome = lib.mkIf (!isServer) {
      tinysparql.enable = true;
      localsearch.enable = true;
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
    ];
  };
}
