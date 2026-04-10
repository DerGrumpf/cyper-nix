{
  config,
  primaryUser,
  inputs,
  self,
  lib,
  isDarwin,
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
    inputs.sops-nix.homeManagerModules.sops
  ]
  ++ lib.optionals (!isDarwin && !isServer) [
    ./desktop
    ./catppuccin.nix
  ]
  ++ lib.optionals isDarwin [
    ./desktop/sketchybar
    ./catppuccin.nix
  ]
  ++ lib.optionals (!isServer) [
    ./nixcord.nix
    ./spicetify.nix
    ./floorp.nix
    ./obsidian.nix
  ];

  nixpkgs.config.allowUnfree = true;

  home = {
    username = primaryUser;
    stateVersion = "26.05";
    sessionVariables = lib.mkIf (!isDarwin && !isServer) {
      GROQ_API_KEY = config.sops.secrets.GROQ_API_KEY.path;
      OPENWEATHER_API_KEY = config.sops.secrets.OPENWEATHER_API_KEY.path;
    };
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
      if isDarwin then
        "/Users/${primaryUser}/.config/nix/secrets/keys.txt"
      else
        "/home/${primaryUser}/.config/nix/secrets/keys.txt";
    secrets = {
      GROQ_API_KEY = { };
      OPENWEATHER_API_KEY = { };
      ssh_private_key = {
        path = if isDarwin then "/Users/${primaryUser}/.ssh/ssh" else "/home/${primaryUser}/.ssh/ssh";
        mode = "0600";
      };
      ssh_github_key = {
        path = if isDarwin then "/Users/${primaryUser}/.ssh/github" else "/home/${primaryUser}/.ssh/github";
        mode = "0600";
      };
    };
  };

  programs.man.enable = false;
}
