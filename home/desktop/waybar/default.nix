{ pkgs, lib, compositor ? "hyprland", ... }: {
  programs.waybar = lib.mkIf (!pkgs.stdenv.isDarwin) ({
    enable = true;
    package = pkgs.waybar;
  } // (import ./dual.nix { inherit compositor; }));

  home.packages = lib.mkIf (!pkgs.stdenv.isDarwin) (with pkgs; [ cava ]);

  home.file = lib.mkIf (!pkgs.stdenv.isDarwin) {
    ".config/waybar" = {
      source = ./configs;
      recursive = true;
    };
  };
}
