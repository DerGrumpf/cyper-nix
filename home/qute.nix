{

  catppuccin.qutebrowser.enable = true;

  programs.qutebrowser = {
    enable = true;
    searchEngines = {
      cy = "https://search.cyperpunk.de/?search={}";
      cj = "https://search.cyperpunk.de/?search={}&format=json";
    };
  };
}
