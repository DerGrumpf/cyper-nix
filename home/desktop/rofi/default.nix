{
  pkgs,
  ...
}:
{
  home = {
    packages = (
      with pkgs;
      [
        rofi-power-menu
        rofi-calc
      ]
    );

    file = {
      ".config/rofi/background.png".source = ./background.png;
      ".config/rofi/custom.rasi".source = ./custom.rasi;
      ".config/rofi/power.jpg".source = ./power.jpg;
      ".config/rofi/power.rasi".source = ./power.rasi;
      ".config/rofi/smoking_girl.png".source = ./smoking_girl.png;
    };
  };

  programs.rofi = {
    enable = true;
    settings = {
      font = "FiraCode Nerd Font Mono 12";
      terminal = "${pkgs.kitty}/bin/kitty";
      cycle = true;
      location = 0;
    };
  };

}
