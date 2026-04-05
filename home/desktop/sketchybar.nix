{ pkgs, lib, ... }:
{
  programs.sketchybar = lib.mkIf pkgs.stdenv.isDarwin {
    enable = true;
    configType = "lua";
    sbarLuaPackage = pkgs.sbarlua;
  };
}
