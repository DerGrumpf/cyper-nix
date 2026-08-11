{
  inputs,
  lib,
  isDarwin,
  ...
}:
{
  imports = [
    inputs.helium-flake.homeModules.default
    inputs.impermanence.homeManagerModules.impermanence
  ];

  home.persistence."/persist".directories = lib.mkIf (!isDarwin) [
    ".config/net.imput.helium"
  ];

  programs.helium = {
    enable = true;
    flags = [
      "--enable-features=TouchpadOverscrollHistoryNavigation"
      "--start-maximized"
    ];
    policies = {
      "BrowserSignin" = 0;

      # New tab / homepage
      "HomepageLocation" = "https://www.cyperpunk.de";
      "HomepageIsNewTabPage" = false;
      "RestoreOnStartup" = 4; # 4 = open specific URLs
      "RestoreOnStartupURLs" = [ "https://www.cyperpunk.de" ];
      "NewTabPageLocation" = "https://www.cyperpunk.de";

      # Search
      "DefaultSearchProviderEnabled" = true;
      "DefaultSearchProviderName" = "cyperpunk";
      "DefaultSearchProviderSearchURL" = "https://search.cyperpunk.de/?q={searchTerms}";

      # Catppuccin Mocha theme, force-installed
      "ExtensionInstallForcelist" = [
        "bkkmolkhemgaeaeggcmfbghljjjoofoh;https://clients2.google.com/service/update2/crx"
      ];
    };
  };
}
