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
    ./fonts.nix
    inputs.sops-nix.homeManagerModules.sops
  ]
  ++ lib.optionals (!isDarwin && !isServer) [
    ./desktop
    ./catppuccin.nix
  ]
  ++ lib.optionals (!isDarwin) [
    ./opencode.nix
  ]
  ++ lib.optionals isDarwin [
    ./desktop/sketchybar
    ./catppuccin.nix
  ]
  ++ lib.optionals (!isServer) [
    ./nixcord.nix
    ./spicetify.nix
    ./floorp
    ./obsidian.nix
  ];

  home = {
    username = primaryUser;
    enableNixpkgsReleaseCheck = false;
    stateVersion = "26.05";
    sessionVariables = lib.mkIf (!isDarwin && !isServer) {
      GROQ_API_KEY = config.sops.secrets."api_keys/groq".path;
      OPENWEATHER_API_KEY = config.sops.secrets."api_keys/openweather".path;
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
        "/persist/secrets/age-key.txt";
    secrets = {
      "api_keys/groq" = { };
      "api_keys/openweather" = { };
      "ssh/private_key" = {
        path = if isDarwin then "/Users/${primaryUser}/.ssh/ssh" else "/home/${primaryUser}/.ssh/ssh";
        mode = "0600";
      };
      "ssh/github_key" = {
        path = if isDarwin then "/Users/${primaryUser}/.ssh/github" else "/home/${primaryUser}/.ssh/github";
        mode = "0600";
      };
    };
  };

  programs.man.enable = false;
}
