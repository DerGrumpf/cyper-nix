{ pkgs, config, ... }:
let
  browser = [ "floorp.desktop" ];

  # XDG MIME types
  associations = {
    "application/x-extension-htm" = browser;
    "application/x-extension-html" = browser;
    "application/x-extension-shtml" = browser;
    "application/x-extension-xht" = browser;
    "application/x-extension-xhtml" = browser;
    "application/xhtml+xml" = browser;
    "text/html" = browser;
    "x-scheme-handler/about" = browser;
    "x-scheme-handler/chrome" = [ "chromium-browser.desktop" ];
    "x-scheme-handler/ftp" = browser;
    "x-scheme-handler/http" = browser;
    "x-scheme-handler/https" = browser;
    "x-scheme-handler/unknown" = browser;

    "audio/*" = [ "mpv.desktop" ];
    "video/*" = [ "mpv.desktop" ];
    "image/*" = [ "swayimg.desktop" ];
    #"application/json" = browser;
    "application/pdf" = [ "okular.desktop" ];
    "x-scheme-handler/discord" = [ "discordcanary.desktop" ];
    "x-scheme-handler/spotify" = [ "spotify.desktop" ];
    "x-scheme-handler/tg" = [ "telegramdesktop.desktop" ];

    "text/csv" = [ "gnumeric.desktop" ];
    "application/csv" = [ "gnumeric.desktop" ];
    "text/tab-separated-values" = [ "gnumeric.desktop" ];
    "application/tsv" = [ "gnumeric.desktop" ];
    "application/json" = [ "kitty-tabiew.desktop" ];
    "application/x-ndjson" = [ "kitty-tabiew.desktop" ];
    "application/vnd.apache.arrow.file" = [ "kitty-tabiew.desktop" ];
    "application/parquet" = [ "kitty-tabiew.desktop" ];
    "application/x-parquet" = [ "kitty-tabiew.desktop" ];
    "application/vnd.sqlite3" = [ "sqlitebrowser.desktop" ];
    "application/x-sqlite3" = [ "sqlitebrowser.desktop" ];
    "application/fwf" = [ "kitty-tabiew.desktop" ];
    "text/fwf" = [ "kitty-tabiew.desktop" ];

  };
in
{
  xdg = {
    enable = true;
    cacheHome = config.home.homeDirectory + "/.local/cache";

    mimeApps = {
      enable = true;
      defaultApplications = associations;
    };

    desktopEntries = {
      kitty-tabiew = {
        name = "Tabiew CSV Viewer";
        exec = "kitty -e tw %F --theme catppuccin";
        terminal = false;
        type = "Application";
        mimeType = [
          "text/csv"
          "application/csv"
          "text/tab-separated-values"
          "application/tsv"
          "application/json"
          "application/x-ndjson"
          "application/vnd.apache.arrow.file"
          "application/parquet"
          "application/x-parquet"
          "application/vnd.sqlite3"
          "application/x-sqlite3"
          "application/fwf"
          "text/fwf"
        ];
        categories = [
          "Utility"
          "Viewer"
          "Database"
          "Development"
        ];
      };
    };

    userDirs = {
      enable = true;
      createDirectories = true;
      extraConfig = {
        XDG_SCREENSHOTS_DIR = "${config.xdg.userDirs.pictures}/Screenshots";
      };
    };
  };
}
