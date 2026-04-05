{ pkgs, lib, ... }:
{
  qt = lib.mkIf (!pkgs.stdenv.isDarwin) {
    enable = true;
    style.name = "kvantum";
    platformTheme.name = "kvantum";
  };
  home.packages = lib.mkIf (!pkgs.stdenv.isDarwin) (
    with pkgs;
    [
      kdePackages.qt6ct
      kdePackages.qtstyleplugin-kvantum
    ]
  );
}
