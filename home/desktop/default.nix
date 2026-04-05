{ pkgs, inputs, ... }: {
  imports = [
    inputs.catppuccin.homeModules.catppuccin
    ./hyprland
    ./rofi
    ./waybar
    ./gtk.nix
    ./qt.nix
  ];

  _module.args.compositor = "hyprland";

  home.packages = with pkgs; [ waypaper awww ];
  home.file.".config/waypaper/config.ini".source = ./waypaper.ini;

  programs = {
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
    mpv.enable = true;
  };
}
