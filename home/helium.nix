{
  inputs,
  ...
}:
{
  imports = [ inputs.helium-flake.homeModules.default ];
  home.persistence."/persist".directories = [
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
