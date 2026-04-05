{
  description = "DerGrumpfs Nix Configuration";

  inputs = {
    # monorepo w/ recipes ("derivations")
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    # declarative Configs
    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # declarative Hyprland
    hyprland = {
      url = "github:hyprwm/Hyprland";
      inputs.nixpkgs.follows = "nixpkgs";
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
    nix-homebrew = { url = "github:zhaofengli/nix-homebrew"; };

    # declarative Neovim
    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
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
  };

  outputs = { self, nixpkgs, home-manager, darwin, nix-homebrew, nixvim
    , hyprland, sops-nix, ... }@inputs:
    let
      primaryUser = "phil";

      mkNixos = hostName:
        nixpkgs.lib.nixosSystem {
          modules = [
            {
              nixpkgs.hostPlatform = "x86_64-linux";
              networking.hostName = hostName;
            }
            ./nixos
            ./hosts/cyper-desktop/configuration.nix
            inputs.home-manager.nixosModules.home-manager
            {
              home-manager.extraSpecialArgs = {
                inherit inputs primaryUser self;
                isDarwin = false;
              };
              home-manager.users.${primaryUser} = import ./home;
            }
            inputs.sops-nix.nixosModules.sops
          ];
          specialArgs = {
            inherit inputs primaryUser self hostName;
            isDarwin = false;
          };
        };

      mkDarwin = hostName:
        darwin.lib.darwinSystem {
          system = "x86_64-darwin";
          modules = [
            ./darwin
            ./hosts/cyper-mac/configuration.nix
            { networking.hostName = hostName; }
            inputs.nix-homebrew.darwinModules.nix-homebrew
            inputs.home-manager.darwinModules.home-manager
            {
              home-manager.extraSpecialArgs = {
                inherit inputs primaryUser self;
                isDarwin = true;
              };
              home-manager.users.${primaryUser} = import ./home;
            }
            inputs.sops-nix.darwinModules.sops
          ];
          specialArgs = {
            inherit inputs primaryUser self hostName;
            isDarwin = true;
          };
        };
    in {
      nixosConfigurations."cyper-desktop" = mkNixos "cyper-desktop";
      darwinConfigurations."cyper-mac" = mkDarwin "cyper-mac";
    };
}
