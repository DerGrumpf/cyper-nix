{
  description = "DerGrumpfs Darwin (Intel Mac) Configuration";
  inputs = {
    # nixpkgs 26.05-darwin: last branch with x86_64-darwin support
    # (26.11 dropped it; 26.05 gets security fixes through end of 2026)
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-26.05-darwin";

    darwin = {
      url = "github:nix-darwin/nix-darwin/nix-darwin-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-homebrew = {
      url = "github:zhaofengli/nix-homebrew";
    };

    nur = {
      url = "github:nix-community/NUR";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixvim = {
      url = "github:nix-community/nixvim/nixos-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixcord = {
      url = "github:kaylorben/nixcord";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    spicetify-nix = {
      url = "github:Gerg-L/spicetify-nix";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        systems.url = "github:nix-systems/default/4e9a51a15ceb27e5141819142a7d2ee827943fc8";
      };
    };

    helium-flake = {
      url = "github:oxcl/nix-flake-helium-browser";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      darwin,
      nix-homebrew,
      nur,
      home-manager,
      sops-nix,
      nixvim,
      nixcord,
      helium-flake,
      ...
    }@inputs:
    let
      primaryUser = "phil";
      hostName = "cyper-mac";
      system = "x86_64-darwin";
    in
    {
      darwinConfigurations.${hostName} = darwin.lib.darwinSystem {
        inherit system;
        specialArgs = {
          inherit
            inputs
            primaryUser
            self
            hostName
            ;
        };
        modules = [
          {
            nixpkgs = {
              config.allowUnfree = true;
              overlays = [ nur.overlays.default ];
            };
          }
          ./default.nix
          nix-homebrew.darwinModules.nix-homebrew
          sops-nix.darwinModules.sops
          home-manager.darwinModules.home-manager
          {
            home-manager = {
              extraSpecialArgs = {
                inherit
                  inputs
                  primaryUser
                  self
                  hostName
                  ;
              };
              users.${primaryUser} = import ./home;
              backupFileExtension = "hm-backup";
              sharedModules = [ sops-nix.homeManagerModules.sops ];
              useGlobalPkgs = true;
              useUserPackages = true;
            };
          }
        ];
      };

      formatter.${system} = nixpkgs.legacyPackages.${system}.nixfmt-tree;
    };
}
