{ pkgs, lib, isDarwin, ... }: {
  programs.sketchybar = lib.mkIf isDarwin {
    enable = true;
    configType = "lua";
    sbarLuaPackage = pkgs.sbarlua;
  };

  home.file = lib.mkIf isDarwin {
    ".config/sketchybar/sketchybar.lua".source = ./sketchybar.lua;
    ".config/sketchybar/sketchybarrc".source = ./sketchybarrc;
    ".config/sketchybar/plugins/battery.sh" = {
      source = ./plugins/battery.sh;
      executable = true;
    };
    ".config/sketchybar/plugins/clock.sh" = {
      source = ./plugins/clock.sh;
      executable = true;
    };
    ".config/sketchybar/plugins/front_app.sh" = {
      source = ./plugins/front_app.sh;
      executable = true;
    };
    ".config/sketchybar/plugins/space.sh" = {
      source = ./plugins/space.sh;
      executable = true;
    };
    ".config/sketchybar/plugins/volume.sh" = {
      source = ./plugins/volume.sh;
      executable = true;
    };
  };
}
