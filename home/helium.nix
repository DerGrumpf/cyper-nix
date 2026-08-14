{
  inputs,
  lib,
  isDarwin,
  ...
}:
{
  imports = [ inputs.helium-flake.homeModules.default ];
  home.persistence."/persist".directories = lib.mkIf (!isDarwin) [
    ".config/net.imput.helium"
  ];
  programs.helium = {
    enable = true;
    flags = [
      "--enable-features=TouchpadOverscrollHistoryNavigation"
      "--start-maximized"
    ];
  };
}
