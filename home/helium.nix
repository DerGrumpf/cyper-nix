{
  inputs,
  ...
}:
{
  imports = [
    inputs.helium-flake.homeModules.default
  ];

  programs.helium = {
    enable = true;

    flags = [
      "--enable-features=TouchpadOverscrollHistoryNavigation"
      "--start-maximized"
    ];

    policies = {
      "BrowserSignin" = 0;
    };
  };
}
