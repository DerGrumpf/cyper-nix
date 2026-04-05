{
  pkgs,
  inputs,
  lib,
  ...
}:
{
  imports = [
    inputs.catppuccin.homeModules.catppuccin
    ./hyprland
    ./rofi
    ./waybar
    ./gtk.nix
    ./qt.nix
    ./sketchybar.nix
  ];

  _module.args.compositor = if pkgs.stdenv.isDarwin then "quartz" else "hyprland";

  home = lib.mkIf (!pkgs.stdenv.isDarwin) {
    packages = with pkgs; [
      waypaper
      awww
    ];
    file.".config/waypaper/config.ini".source = ./waypaper.ini;
  };

  # TODO: Qutebrowser install
  programs = lib.mkIf (!pkgs.stdenv.isDarwin) {
    mangohud = {
      enable = true;
      settings = {
        position = "top-right";

        offset_x = 20;
        offset_y = 20;

        fps = true;
        cpu_stats = true;
        gpu_stats = true;
        cpu_temp = true;
        gpu_temp = true;
        ram = true;
        vram = true;

        background_alpha = 0.5;
      };
    };

    # TODO: Needs config!
    mpv = {
      enable = true;

    };
  };
}
