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
    nix-homebrew = {
      url = "github:zhaofengli/nix-homebrew";
    };

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
      ...
    }@inputs:
    let
      primaryUser = "phil";
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
            ./hosts/${hostName}/configuration.nix
            inputs.sops-nix.${platformModuleSet}.sops
            inputs.home-manager.${platformModuleSet}.home-manager
            {
              home-manager = {
                extraSpecialArgs = sharedSpecialArgs;
                users.${primaryUser} = import ./home;
                backupFileExtension = "backup";
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
        "cyper-desktop" = mkSystem {
          hostName = "cyper-desktop";
          system = "x86_64-linux";
        };
        "cyper-node-1" = mkSystem {
          hostName = "cyper-node-1";
          system = "x86_64-linux";
          isServer = true;
        };
      };

      darwinConfigurations."cyper-mac" = mkSystem {
        hostName = "cyper-mac";
        system = "x86_64-darwin";
        isDarwin = true;
      };
    };
}
