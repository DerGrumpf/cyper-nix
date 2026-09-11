{
  primaryUser,
  inputs,
  ...
}:
{
  imports = [ inputs.helium-flake.homeModules.default ];

  home = {
    username = primaryUser;
    homeDirectory = "/Users/${primaryUser}";
    enableNixpkgsReleaseCheck = false;
    stateVersion = "26.05";
  };

  programs = {
    home-manager.enable = true;
    fish.enable = true;
    helium = {
      enable = true;
      flags = [
        "--enable-features=TouchpadOverscrollHistoryNavigation"
        "--start-maximized"
      ];
    };
  };
}
