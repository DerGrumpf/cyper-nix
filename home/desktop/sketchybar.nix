{ pkgs, ... }: {
  programs.sketchybar = {
    enable = true;
    configType = "lua";
    sbarLuaPackage = pkgs.sbarlua;
  };
}
