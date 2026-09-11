{
  description = "DerGrumpfs Darwin (Intel Mac) Configuration";

  inputs = {
    # nixpkgs 26.05-darwin: last branch with x86_64-darwin support
    # (26.11 dropped it; 26.05 gets security fixes through end of 2026)
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-26.05-darwin";

    darwin = {
      url = "github:lnl7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-homebrew = {
      url = "github:zhaofengli/nix-homebrew";
    };

    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
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
      home-manager,
      sops-nix,
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
              overlays = [ (import ../overlays { inherit nur; }) ];
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
              useGlobalPkgs = true;
              useUserPackages = true;
            };
          }
        ];
      };

      formatter.${system} = nixpkgs.legacyPackages.${system}.nixfmt-tree;
    };
}
