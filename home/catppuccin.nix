{
  lib,
  isDarwin,
  inputs,
  ...
}:
{
  imports = [ inputs.catppuccin.homeModules.catppuccin ];

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
    cava = {
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
    newsboat.enable = true;
    mangohud.enable = lib.mkIf (!isDarwin) true;
    gtk.icon.enable = lib.mkIf (!isDarwin) true;
    kvantum = lib.mkIf (!isDarwin) {
      enable = true;
      apply = true;
    };
  };
}
