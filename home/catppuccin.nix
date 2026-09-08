{
  inputs,
  ...
}:
{
  imports = [ inputs.catppuccin.homeModules.catppuccin ];

  home.pointerCursor.enable = true;

  catppuccin = {
    enable = true;
    autoEnable = false;
    accent = "sky";
    flavor = "mocha";
    eza.enable = true;
    fzf.enable = true;
    bat.enable = true;
    element-desktop = {
      enable = true;
      accent = "green";
    };
    btop.enable = true;
    cava = {
      enable = true;
      transparent = true;
    };
    kitty.enable = true;
    lazygit.enable = true;
    yazi.enable = true;
    fish.enable = true;
    cursors = {
      enable = true;
      accent = "sapphire";
    };
    hyprland.enable = false;
    hyprlock = {
      enable = true;
      useDefaultConfig = false;
    };
    waybar = {
      enable = true;
      mode = "createLink";
    };
    mako.enable = true;
    mpv.enable = true;
    newsboat.enable = true;
    mangohud.enable = true;
    gtk.icon.enable = true;
    kvantum = {
      enable = true;
      apply = true;
    };
    opencode.enable = true;
  };
}
