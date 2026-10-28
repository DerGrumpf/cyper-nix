{
  primaryUser,
  inputs,
  self,
  lib,
  isServer,
  ...
}:
{
  imports = [
    ./packages.nix
    ./git.nix
    ./shell.nix
    ./ssh.nix
    ./xdg.nix
    ./neovim
    ./python.nix
    ./fonts.nix
    ./impermanence.nix
    ./opencode.nix
    inputs.sops-nix.homeManagerModules.sops
  ]
  ++ lib.optionals (!isServer) [
    ./desktop
    ./catppuccin.nix
    ./nixcord.nix
    ./spicetify.nix
    ./floorp
    ./obsidian.nix
    ./helium.nix
    #    ./qute.nix
    ./mail.nix
  ];

  home = {
    username = primaryUser;
    enableNixpkgsReleaseCheck = false;
    stateVersion = "26.11";
    file = lib.mkIf (!isServer) {
      "Pictures/Avatar" = {
        source = "${self}/assets/avatar";
        recursive = true;
      };
      "Pictures/Wallpapers" = {
        source = "${self}/assets/wallpapers";
        recursive = true;
      };
    };
  };

  sops = {
    defaultSopsFile = ../secrets/secrets.yaml;
    defaultSopsFormat = "yaml";
    age.keyFile =

      "/persist/secrets/age-key.txt";
    secrets = {
      "ssh/private_key" = {
        path = "/home/${primaryUser}/.ssh/ssh";
        mode = "0600";
      };
      "ssh/github_key" = {
        path = "/home/${primaryUser}/.ssh/github";
        mode = "0600";
      };
    };
  };

  programs.man.enable = false;
}
