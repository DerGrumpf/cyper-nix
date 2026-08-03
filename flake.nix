{
  description = "DerGrumpfs Nix Configuration";

  inputs = {
    # monorepo w/ recipes ("derivations")
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    # declarative disk layout
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # declarative impermanence
    impermanence = {
      url = "github:nix-community/impermanence";
    };

    nixos-hardware = {
      url = "github:NixOS/nixos-hardware/master";
    };

    # declarative installer
    nixos-anywhere = {
      url = "github:nix-community/nixos-anywhere";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # declarative Configs
    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # NIX User Repositorys
    nur = {
      url = "github:nix-community/NUR";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # declarative Hyprland
    hyprland = {
      url = "github:hyprwm/Hyprland";
    };

    hyprland-plugins = {
      url = "github:hyprwm/hyprland-plugins";
      inputs.hyprland.follows = "hyprland";
    };

    hyprcursor = {
      url = "github:hyprwm/hyprcursor";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # system-level software and settings (macOS)
    darwin = {
      url = "github:lnl7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # declarative homebrew management
    nix-homebrew = {
      url = "github:zhaofengli/nix-homebrew";
    };

    # declarative Neovim
    nixvim = {
      url = "github:nix-community/nixvim";
    };

    # declarative Discord
    nixcord = {
      url = "github:kaylorben/nixcord";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # declarative Spotify
    spicetify-nix = {
      url = "github:Gerg-L/spicetify-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # declarative Encryption
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # declarative Catppuccin
    catppuccin = {
      url = "github:catppuccin/nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Helium Overlay
    helium-flake = {
      url = "github:oxcl/nix-flake-helium-browser";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      darwin,
      nix-homebrew,
      nixvim,
      hyprland,
      sops-nix,
      nur,
      impermanence,
      disko,
      nixos-anywhere,
      helium-flake,
      ...
    }@inputs:
    let
      primaryUser = "phil";

      mkInstaller =
        {
          system,
          configPath,
        }:
        nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = { inherit inputs; };
          modules = [
            {
              nixpkgs = {
                config.allowUnfree = true;
                hostPlatform = system;
              };
            }
            configPath
          ];
        };

      installer = mkInstaller {
        system = "x86_64-linux";
        configPath = ./hosts/installer/configuration.nix;
      };

      installerPi = mkInstaller {
        system = "aarch64-linux";
        configPath = ./hosts/installer-pi/configuration.nix;
      };

      mkInstall =
        {
          hostName,
          target ? "192.168.2.99",
        }:
        let
          pkgs = nixpkgs.legacyPackages.x86_64-linux;
        in
        {
          type = "app";
          program = "${
            pkgs.writeShellApplication {
              name = "install-${hostName}";
              runtimeInputs = [ nixos-anywhere.packages.x86_64-linux.nixos-anywhere ];
              text = ''
                EXTRA_FILES="''${1:-./extra-files}"
                TARGET="''${2:-${target}}"
                nixos-anywhere \
                  --flake .#${hostName} \
                  --extra-files "$EXTRA_FILES" \
                  --chown /persist/secrets/age-key.txt "$(id -u ${primaryUser})":100 \
                  root@"$TARGET"
              '';
            }
          }/bin/install-${hostName}";

          meta.description = "Install NixOS on ${hostName} via nixos-anywhere";
        };

      mkSystem =
        {
          hostName,
          system,
          isDarwin ? false,
          isServer ? false,
        }:
        let
          systemFunc = if isDarwin then darwin.lib.darwinSystem else nixpkgs.lib.nixosSystem;
          platformModuleSet = if isDarwin then "darwinModules" else "nixosModules";

          sharedSpecialArgs = {
            inherit
              inputs
              primaryUser
              self
              hostName
              isDarwin
              isServer
              ;
          };

          sharedModules = [
            { networking.hostName = hostName; }
            {
              nixpkgs = {
                overlays = [
                  (import ./overlays { inherit (inputs) nur; })
                  helium-flake.overlays.default
                ];
                config.allowUnfree = true;
              };
            }
            ./hosts/${hostName}/configuration.nix
            inputs.sops-nix.${platformModuleSet}.sops
            inputs.home-manager.${platformModuleSet}.home-manager
            {
              home-manager = {
                extraSpecialArgs = sharedSpecialArgs;
                users.${primaryUser} = import ./home;
                backupFileExtension = "hm-backup";
                useGlobalPkgs = true;
                useUserPackages = true;
                sharedModules = [
                  { programs.nixvim.nixpkgs.useGlobalPackages = true; }
                ];
              };
            }
          ];

          platformModules =
            if isDarwin then
              [
                ./darwin
                inputs.nix-homebrew.darwinModules.nix-homebrew
              ]
            else
              [
                { nixpkgs.hostPlatform = system; }
                ./nixos
                inputs.impermanence.nixosModules.impermanence
                inputs.disko.nixosModules.disko
              ];

        in
        systemFunc {
          inherit system;
          modules = sharedModules ++ platformModules;
          specialArgs = sharedSpecialArgs;
        };
    in
    {
      nixosConfigurations = {
        "installer" = installer;

        "installer-pi" = installerPi;

        "cyper-desktop" = mkSystem {
          hostName = "cyper-desktop";
          system = "x86_64-linux";
        };

        "cyper-controller" = mkSystem {
          hostName = "cyper-controller";
          system = "x86_64-linux";
          isServer = true;
        };

        "cyper-proxy" = mkSystem {
          hostName = "cyper-proxy";
          system = "x86_64-linux";
          isServer = true;
        };

        "cyper-node-1" = mkSystem {
          hostName = "cyper-node-1";
          system = "x86_64-linux";
          isServer = true;
        };

        "cyper-node-2" = mkSystem {
          hostName = "cyper-node-2";
          system = "x86_64-linux";
          isServer = true;
        };

        "cyper-pi-1" = mkSystem {
          hostName = "cyper-pi-1";
          system = "aarch64-linux";
          isServer = true;
        };
      };

      darwinConfigurations."cyper-mac" = mkSystem {
        hostName = "cyper-mac";
        system = "x86_64-darwin";
        isDarwin = true;
      };

      packages.x86_64-linux = {
        installer = self.nixosConfigurations.installer.config.system.build.isoImage;
      };

      formatter.x86_64-linux = nixpkgs.legacyPackages.x86_64-linux.nixfmt-tree;

      apps.x86_64-linux = {
        install-cyper-node-1 = mkInstall {
          hostName = "cyper-node-1";
        };
        install-cyper-node-2 = mkInstall {
          hostName = "cyper-node-2";
        };
        install-cyper-controller = mkInstall {
          hostName = "cyper-controller";
        };
        install-cyper-proxy = mkInstall {
          hostName = "cyper-proxy";
          target = ""; # KVM console IP
        };
        install-cyper-desktop = mkInstall {
          hostName = "cyper-desktop";
        };
        install-cyper-pi-1 = mkInstall {
          hostName = "cyper-pi-1";
          target = "192.168.2.197";
        };
      };

      hydraJobs = {
        cyper-desktop = self.nixosConfigurations.cyper-desktop.config.system.build.toplevel;
        cyper-controller = self.nixosConfigurations.cyper-controller.config.system.build.toplevel;
        cyper-proxy = self.nixosConfigurations.cyper-proxy.config.system.build.toplevel;
        cyper-node-1 = self.nixosConfigurations.cyper-node-1.config.system.build.toplevel;
        cyper-node-2 = self.nixosConfigurations.cyper-node-2.config.system.build.toplevel;
        cyper-pi-1 = self.nixosConfigurations.cyper-pi-1.config.system.build.toplevel;
      };
    };
}
