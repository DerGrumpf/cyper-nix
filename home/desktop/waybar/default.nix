{
  pkgs,
  compositor ? "hyprland",
  ...
}:
{
  sops.secrets."system/openweather" = {
    mode = "0400";
  };

  programs.waybar = {
    enable = true;
    package = pkgs.waybar;
  }
  // (import ./dual.nix { inherit compositor; });

  home = {
    packages = with pkgs; [ cava ];

    file = {
      ".config/waybar" = {
        source = ./configs;
        recursive = true;
      };
    };
  };
}
