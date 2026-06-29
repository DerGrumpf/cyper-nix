{
  pkgs,
  inputs,
  primaryUser,
  ...
}:
{
  imports = [
    inputs.spicetify-nix.homeManagerModules.default
  ];

  home.persistence."/persist/home/${primaryUser}".directories = [
    ".config/spotify"
  ];

  programs.spicetify =
    let
      spicePkgs = inputs.spicetify-nix.legacyPackages.${pkgs.system};
    in
    {
      enable = true;
      spotifyPackage = pkgs.spotify;
      theme = spicePkgs.themes.catppuccin;
      colorScheme = "mocha";

      enabledExtensions = with spicePkgs.extensions; [
        bookmark
        fullAppDisplay
        keyboardShortcut
        popupLyrics
        shuffle
        autoVolume
        betterGenres
        adblock
        wikify
        songStats
      ];

      enabledCustomApps = with spicePkgs.apps; [
        lyricsPlus
        newReleases
        marketplace
      ];

      #enabledSnippets = with spicePkgs.snippets; [ ];

    };
}
