{
  pkgs,
  ...
}:
{

  home.packages = with pkgs; [
    rofi-power-menu
    rofi-calc
  ];

  programs.rofi = {
    enable = true;
    cycle = true;
    package = pkgs.rofi;
    font = "FiraCode Nerd Font Mono 12";

    location = "center";
    terminal = "${pkgs.kitty}/bin/kitty";

  };

  home.file = {
    ".config/rofi/background.png".source = ./background.png;
    ".config/rofi/custom.rasi".source = ./custom.rasi;
    ".config/rofi/power.jpg".source = ./power.jpg;
    ".config/rofi/power.rasi".source = ./power.rasi;
    ".config/rofi/smoking_girl.png".source = ./smoking_girl.png;
  };

}
