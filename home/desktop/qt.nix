{ pkgs, ... }:
{
  qt = {
    enable = true;
    style.name = "kvantum";
    platformTheme.name = "kvantum";
  };
  home.packages = with pkgs; [
    kdePackages.qt6ct
    kdePackages.qtstyleplugin-kvantum
  ];
}
