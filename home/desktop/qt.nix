{
  pkgs,
  lib,
  isDarwin,
  ...
}:
{
  qt = lib.mkIf (!isDarwin) {
    enable = true;
    style.name = "kvantum";
    platformTheme.name = "kvantum";
  };
  home.packages = lib.mkIf (!isDarwin) (
    with pkgs.kdePackages;
    [
      qt6ct
      qtstyleplugin-kvantum
    ]
  );
}
