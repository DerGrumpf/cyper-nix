{
  self,
  primaryUser,
  lib,
  ...
}:
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

    activationScripts.postActivation.text = lib.mkAfter ''
      /usr/bin/osascript -e 'tell application "System Events" to tell every desktop to set picture to "/Users/${primaryUser}/Pictures/Wallpapers/lucy_with_cat.png"'
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
          (apps "Helium")
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
