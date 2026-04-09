{ self, ... }:
{
  # touch ID for sudo
  security.pam.services.sudo_local.touchIdAuth = true;

  # system defaults and preferences
  system = {
    stateVersion = 6;
    configurationRevision = self.rev or self.dirtyRev or null;

    startup.chime = false;

    activationScripts = {
      setWallpaper.text = ''
        /usr/bin/osascript <<EOF
        tell application "System Events"
          tell every desktop
            set picture to "/Users/phil/Pictures/Wallpapers/Ghost_in_the_Shell.png"
          end tell
        end tell
        EOF
      '';

    };

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
        persistent-apps = [
          { app = "/Users/phil/Applications/Home Manager Apps/kitty.app"; }
          { app = "/Users/phil/Applications/Home Manager Apps/Vesktop.app"; }
          { app = "/Users/phil/Applications/Home Manager Apps/Spotify.app"; }
          { app = "/Users/phil/Applications/Home Manager Apps/Floorp.app"; }
          { app = "/Users/phil/Applications/Home Manager Apps/Obsidian.app"; }
          { app = "/Users/phil/Applications/Home Manager Apps/OpenSCAD.app"; }
          { app = "/Applications/okular.app"; }
          { app = "/Applications/Affinity.app"; }
          { app = "/System/Applications/Mail.app"; }
          { app = "/System/Applications/Launchpad.app"; }
        ];
        show-recents = false;
        mineffect = "genie";
      };

      loginwindow = {
        GuestEnabled = false;
        DisableConsoleAccess = true;
      };

      finder = {
        AppleShowAllFiles = true; # hidden files
        AppleShowAllExtensions = true; # file extensions
        _FXShowPosixPathInTitle = true; # title bar full path
        ShowPathbar = true; # breadcrumb nav at bottom
        ShowStatusBar = true; # file count & disk space
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
