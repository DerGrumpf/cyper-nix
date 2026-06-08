{ self, primaryUser, ... }:
let
  hmApps = app: "/Users/${primaryUser}/Applications/Home Manager Apps/${app}.app";
  sysApps = app: "/System/Applications/${app}.app";
  apps = app: "/Applications/${app}.app";
in
{
  security.pam.services.sudo_local.touchIdAuth = true;

  system = {
    stateVersion = 6;
    configurationRevision = self.rev or self.dirtyRev or null;

    startup.chime = false;

    activationScripts.setWallpaper.text = ''
      /usr/bin/osascript <<EOF
      tell application "System Events"
        tell every desktop
          set picture to "/Users/${primaryUser}/Pictures/Wallpapers/Ghost_in_the_Shell.png"
        end tell
      end tell
      EOF
    '';

    defaults = {
      ActivityMonitor = {
        IconType = 5;
        OpenMainWindow = true;
        ShowCategory = 101;
      };

      dock = {
        enable-spring-load-actions-on-all-items = true;
        appswitcher-all-displays = false;
        autohide = false;
        launchanim = true;
        mru-spaces = false;
        orientation = "left";
        show-recents = false;
        mineffect = "genie";
        persistent-apps = map (app: { inherit app; }) [
          (hmApps "kitty")
          (hmApps "Vesktop")
          (hmApps "Spotify")
          (hmApps "Floorp")
          (hmApps "Obsidian")
          (hmApps "OpenSCAD")
          (apps "okular")
          (apps "Affinity")
          (apps "Element")
          (sysApps "Mail")
          (sysApps "Launchpad")
        ];
      };

      loginwindow = {
        GuestEnabled = false;
        DisableConsoleAccess = true;
      };

      finder = {
        AppleShowAllFiles = true;
        AppleShowAllExtensions = true;
        _FXShowPosixPathInTitle = true;
        ShowPathbar = true;
        ShowStatusBar = true;
      };

      NSGlobalDomain = {
        NSAutomaticSpellingCorrectionEnabled = false;
        NSAutomaticCapitalizationEnabled = false;
        NSAutomaticPeriodSubstitutionEnabled = false;
        NSAutomaticWindowAnimationsEnabled = false;
      };
    };
  };
}
