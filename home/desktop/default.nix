{ pkgs, inputs, ... }: {
  imports = [ inputs.catppuccin.homeModules.catppuccin ]
    ++ pkgs.lib.optionals (!pkgs.stdenv.isDarwin) [
      ./hyprland
      ./rofi
      ./waybar
      ./gtk.nix
      ./qt.nix
    ] ++ pkgs.lib.optionals pkgs.stdenv.isDarwin [ ./sketchybar.nix ];

  _module.args.compositor =
    if pkgs.stdenv.isDarwin then "quartz" else "hyprland";

  home = pkgs.lib.mkIf (!pkgs.stdenv.isDarwin) {
    packages = with pkgs; [ waypaper swww ];
    file.".config/waypaper/config.ini".source = ./waypaper.ini;
  };

  # TODO: Qutebrowser install
  programs = pkgs.lib.mkIf (!pkgs.stdenv.isDarwin) {
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
