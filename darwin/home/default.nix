{
  primaryUser,
  ...
}:
{
  imports = [
    ./floorp.nix
    ../sketchybar
  ];

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
