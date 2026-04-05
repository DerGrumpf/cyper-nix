{ config, primaryUser, inputs, self, lib, isDarwin, ... }: {
  imports = [
    ./packages.nix
    ./git.nix
    ./shell.nix
    ./xdg.nix
    ./neovim
    ./python.nix
    ./nixcord.nix
    ./spicetify.nix
    ./floorp.nix
    ./obsidian.nix
    inputs.sops-nix.homeManagerModules.sops
  ] ++ lib.optionals (!isDarwin) [ ./desktop ] ++ lib.optionals isDarwin [
    ./desktop/sketchybar
    inputs.catppuccin.homeModules.catppuccin
  ];
  nixpkgs.config.allowUnfree = true;

  catppuccin = {
    enable = false;
    accent = "sky";
    flavor = "mocha";

    eza.enable = true;
    fzf.enable = true;
    bat.enable = true;

    element-desktop = lib.mkIf (!isDarwin) {
      enable = true;
      accent = "green";
    };

    btop.enable = true;

    cava = lib.mkIf (!isDarwin) {
      enable = true;
      transparent = true;
    };

    kitty.enable = true;
    lazygit.enable = true;
    yazi.enable = true;
    fish.enable = true;

    cursors = lib.mkIf (!isDarwin) {
      enable = true;
      accent = "sapphire";
    };

    hyprland = lib.mkIf (!isDarwin) { enable = true; };

    hyprlock = lib.mkIf (!isDarwin) {
      enable = true;
      useDefaultConfig = false;
    };

    waybar = lib.mkIf (!isDarwin) {
      enable = true;
      mode = "createLink";
    };

    mako.enable = lib.mkIf (!isDarwin) true;
    mpv.enable = lib.mkIf (!isDarwin) true;
    newsboat.enable = lib.mkIf (!isDarwin) true;
    mangohud.enable = lib.mkIf (!isDarwin) true;

    gtk.icon.enable = lib.mkIf (!isDarwin) true;

    kvantum = lib.mkIf (!isDarwin) {
      enable = true;
      apply = true;
    };
  };

  home = {
    username = primaryUser;
    stateVersion = "26.05";
    sessionVariables = lib.mkIf (!isDarwin) {
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
    age.keyFile = if isDarwin then
      "/Users/${primaryUser}/.config/nix/secrets/keys.txt"
    else
      "/home/${primaryUser}/.config/nix/secrets/keys.txt";

    secrets = {
      GROQ_API_KEY = { };
      OPENWEATHER_API_KEY = { };
      ssh_private_key = {
        path = if isDarwin then
          "/Users/${primaryUser}/.ssh/ssh"
        else
          "/home/${primaryUser}/.ssh/ssh";
        mode = "0600";
      };
    };
  };

  programs.man.enable = false;
}
