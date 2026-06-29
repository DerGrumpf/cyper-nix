{ pkgs, ... }:
{
  imports = [
    ./hypridle.nix
    ./hyprlock.nix
    ./mako.nix
    ./portal.nix
  ];

  home.packages = with pkgs; [
    catppuccin-cursors.mochaDark
    grim
    slurp
    wl-clipboard
    pamixer
    brightnessctl
    playerctl
    waypaper
  ];

  systemd.user.targets.hyprland-session.Unit.Wants = [ "xdg-desktop-autostart.target" ];

  services.awww.enable = true;

  wayland.windowManager.hyprland = {
    package = null;
    enable = true;

    xwayland.enable = true;

    systemd = {
      enable = true;
      variables = [ "--all" ];
      enableXdgAutostart = false;
    };

    extraConfig = builtins.readFile ./hyprland-scrolling.lua;
  };
}
