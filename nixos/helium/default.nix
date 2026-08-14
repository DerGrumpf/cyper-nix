{
  inputs,
  ...
}:
{
  imports = [ inputs.helium-flake.nixosModules.default ];

  programs.helium = {
    enable = true;

    policies = {
      "BrowserSignin" = 0;
      "PasswordManagerEnabled" = false;

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
    };
  };
}
