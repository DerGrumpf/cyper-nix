{ pkgs, lib, ... }:
let
  theme = pkgs.magnetic-catppuccin-gtk;
  theme_name = "Catppuccin-GTK-Dark";
in
{
  home = lib.mkIf (!pkgs.stdenv.isDarwin) {
    packages = with pkgs; [
      adwaita-icon-theme
    ];
    #pointerCursor = {
    #  gtk.enable = true;
    #  name = "catppuccin-mocha-sapphire-cursors";
    #  package = pkgs.catppuccin-cursors.mochaSapphire;
    #  size = 24;
    #};
    file = {
      ".config/gtk-4.0/gtk.css".source = "${theme}/share/themes/${theme_name}/gtk-4.0/gtk.css";
      ".config/gtk-4.0/gtk-dark.css".source = "${theme}/share/themes/${theme_name}/gtk-4.0/gtk-dark.css";
      ".config/gtk-4.0/assets".source = "${theme}/share/themes/${theme_name}/gtk-4.0/assets";
    };
  };
  gtk = lib.mkIf (!pkgs.stdenv.isDarwin) {
    enable = true;
    font = {
      name = "FiraCode Nerd Font Propo";
      size = 12;
    };
    theme = {
      name = theme_name;
      package = theme;
    };
    iconTheme = {
      name = "Papirus-Dark";
      package = lib.mkForce (
        pkgs.catppuccin-papirus-folders.override {
          accent = "sky";
          flavor = "mocha";
        }
      );
    };
    gtk3.extraConfig.gtk-application-prefer-dark-theme = 1;
  };
  dconf = lib.mkIf (!pkgs.stdenv.isDarwin) {
    enable = true;
    settings = {
      "org/gnome/desktop/interface" = {
        color-scheme = "prefer-dark";
        gtk-theme = theme_name;
      };
    };
  };
}
