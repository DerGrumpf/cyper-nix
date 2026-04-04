{ config, primaryUser, inputs, self, pkgs, lib, ... }: {
  imports = [

    ./packages.nix
    ./git.nix
    ./shell.nix

    ./neovim
    ./python.nix

    ./nixcord.nix

    ./spicetify.nix

    ./floorp.nix
    ./obsidian.nix

    ./desktop

    inputs.sops-nix.homeManagerModules.sops
  ] ++ lib.optionals (!pkgs.stdenv.isDarwin) [ ./xdg.nix ];

  catppuccin = {
    enable = false;
    accent = "sky";
    flavor = "mocha";

    eza.enable = true;
    fzf.enable = true;
    bat.enable = true;

    element-desktop = pkgs.lib.mkIf (!pkgs.stdenv.isDarwin) {
      enable = true;
      accent = "green";
    };

    btop.enable = true;

    cava = pkgs.lib.mkIf (!pkgs.stdenv.isDarwin) {
      enable = true;
      transparent = true;
    };

    kitty.enable = true;
    lazygit.enable = true;
    yazi.enable = true;
    fish.enable = true;

    cursors = pkgs.lib.mkIf (!pkgs.stdenv.isDarwin) {
      enable = true;
      accent = "sapphire";
    };

    hyprland = pkgs.lib.mkIf (!pkgs.stdenv.isDarwin) { enable = true; };

    hyprlock = pkgs.lib.mkIf (!pkgs.stdenv.isDarwin) {
      enable = true;
      useDefaultConfig = false;
    };

    waybar = pkgs.lib.mkIf (!pkgs.stdenv.isDarwin) {
      enable = true;
      mode = "createLink";
    };

    mako.enable = pkgs.lib.mkIf (!pkgs.stdenv.isDarwin) true;
    mpv.enable = pkgs.lib.mkIf (!pkgs.stdenv.isDarwin) true;
    newsboat.enable = pkgs.lib.mkIf (!pkgs.stdenv.isDarwin) true;
    mangohud.enable = pkgs.lib.mkIf (!pkgs.stdenv.isDarwin) true;

    gtk.icon.enable = pkgs.lib.mkIf (!pkgs.stdenv.isDarwin) true;

    kvantum = pkgs.lib.mkIf (!pkgs.stdenv.isDarwin) {
      enable = true;
      apply = true;
    };
  };

  home = {
    username = primaryUser;
    stateVersion = "26.05";
    sessionVariables = lib.mkIf (!pkgs.stdenv.isDarwin) {
      GROQ_API_KEY = config.sops.secrets.GROQ_API_KEY.path;
      OPENWEATHER_API_KEY = config.sops.secrets.OPENWEATHER_API_KEY.path;
    };

    file = {
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
    age.keyFile = if pkgs.stdenv.isDarwin then
      "/Users/${primaryUser}/.config/nix/secrets/keys.txt"
    else
      "/home/${primaryUser}/.config/nix/secrets/keys.txt";

    secrets = {
      GROQ_API_KEY = { };
      OPENWEATHER_API_KEY = { };
      ssh_private_key = {
        path = if pkgs.stdenv.isDarwin then
          "/Users/${primaryUser}/.ssh/ssh"
        else
          "/home/${primaryUser}/.ssh/ssh";
        mode = "0600";
      };
    };
  };

  programs.man.enable = false;
}
