{
  pkgs,
  lib,
  isDarwin,
  compositor ? "hyprland",
  ...
}:
{
  programs.waybar = lib.mkIf (!isDarwin) (
    {
      enable = true;
      package = pkgs.waybar;
    }
    // (import ./dual.nix { inherit compositor; })
  );

  home = {
    packages = lib.mkIf (!isDarwin) (with pkgs; [ cava ]);

    file = lib.mkIf (!isDarwin) {
      ".config/waybar" = {
        source = ./configs;
        recursive = true;
      };
    };
  };
}
