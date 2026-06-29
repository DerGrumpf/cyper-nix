{ pkgs, primaryUser, ... }:
let
  addons = pkgs.nur.repos.rycee.firefox-addons;
  readJson = path: builtins.readFile path;
  buildXpi =
    {
      name,
      addonId,
      version,
      url,
      sha256,
    }:
    pkgs.nur.repos.rycee.firefox-addons.buildFirefoxXpiAddon {
      pname = name;
      inherit
        addonId
        version
        url
        sha256
        ;
      meta = { };
    };
in
{
  home.persistence."/persist/home".directories = [
    ".mozilla/firefox/${primaryUser}"
  ];

  programs.floorp = {
    enable = true;

    policies.ExtensionSettings = {
      "adguardadblocker@adguard.com" = {
        installation_mode = "force_installed";
        install_url = "https://addons.mozilla.org/firefox/downloads/file/4805625/adguard_adblocker-5.4.3.1.xpi";
        default_area = "navbar";
      };
      "{446900e4-71c2-419f-a6a7-df9c091e268b}" = {
        installation_mode = "force_installed";
        default_area = "navbar";
      }; # Bitwarden
      "{7a7a4a92-a2a0-41d1-9fd7-1e92480d612d}" = {
        installation_mode = "force_installed";
        default_area = "navbar";
      }; # Stylus
      "newtaboverride@agenedia.com" = {
        installation_mode = "force_installed";
      };
      "{3c078156-979c-498b-8990-85f7987dd929}" = {
        installation_mode = "force_installed";
      };
      "firefox@tampermonkey.net" = {
        installation_mode = "force_installed";
      };
      "{7aa7c68a-141f-45c9-a1c6-6e7382debbe1}" = {
        installation_mode = "force_installed";
        install_url = "https://addons.mozilla.org/firefox/downloads/file/4147586/catppuccin_mocha-1.0.xpi";
      };
    };

    profiles.default = {
      isDefault = true;

      extraConfig = ''
        user_pref("extensions.activeThemeID", "{7aa7c68a-141f-45c9-a1c6-6e7382debbe1}");
      '';

      settings = {
        # Startup
        "browser.startup.homepage" = "https://www.cyperpunk.de";

        # UI
        "browser.ctrlTab.sortByRecentlyUsed" = true;
        "browser.tabs.closeWindowWithLastTab" = false;
        "browser.toolbars.bookmarks.visibility" = "never";
        "browser.toolbars.bookmarks.showOtherBookmarks" = false;
        "browser.download.useDownloadDir" = false;
        "general.autoScroll" = true;
        "intl.locale.requested" = "en";
        "browser.search.region" = "DE";

        # New tab
        "browser.newtabpage.activity-stream.feeds.topsites" = false;
        "browser.newtabpage.activity-stream.showSponsoredTopSites" = false;
        "browser.newtabpage.activity-stream.showSponsoredCheckboxes" = false;
        "browser.newtab.extensionControlled" = true;

        # Privacy
        "signon.rememberSignons" = false;
        "privacy.clearOnShutdown_v2.formdata" = true;
        "dom.disable_open_during_load" = false;

        # Devtools
        "devtools.cache.disabled" = true;

        # Media
        "media.eme.enabled" = true;

        # Font
        "font.name.serif.x-western" = "FiraMono Nerd Font";

        # URL bar
        "browser.urlbar.shortcuts.actions" = false;
        "browser.urlbar.shortcuts.bookmarks" = false;
        "browser.urlbar.shortcuts.history" = false;
        "browser.urlbar.suggest.bookmark" = false;

        # Extensions — skip manual enable prompt on fresh install
        "extensions.autoDisableScopes" = 0;

        # Floorp specific
        "floorp.browser.tabs.openNewTabPosition" = -1;
        "floorp.commandPalette.enabled" = true;
        "floorp.mousegesture.enabled" = false;
        "floorp.panelSidebar.enabled" = true;
        "floorp.workspaces.enabled" = true;
        "floorp.zenmode.enabled" = false;
        "floorp.design.configs" = readJson ./design.json;
        "floorp.panelSidebar.config" = readJson ./panel-sidebar.json;
        "floorp.panelSidebar.data" = readJson ./panel-sidebar-data.json;
        "floorp.tabs.sleep.exclusion" = readJson ./tabs-sleep-exclusion.json;
      };

      search = {
        force = true;
        default = "SearXNG";
        engines = {
          "SearXNG" = {
            urls = [ { template = "https://search.cyperpunk.de/search?q={searchTerms}"; } ];
            definedAliases = [ "@sx" ];
          };
        };
      };

      extensions = {
        force = true;
        packages = [
          addons.bitwarden
          addons.sidebery
          addons.tampermonkey
          addons.stylus
          addons.new-tab-override

          (buildXpi {
            name = "adguard-adblocker";
            addonId = "adguardadblocker@adguard.com";
            version = "5.4.3.1";
            url = "https://addons.mozilla.org/firefox/downloads/file/4805625/adguard_adblocker-5.4.3.1.xpi";
            sha256 = "1rqp8qcc0p6qgqfgpshiqnll5mrl9jyfnks4zygzim436k0k781l";
          })

          (buildXpi {
            name = "catppuccin-mocha";
            addonId = "{7aa7c68a-141f-45c9-a1c6-6e7382debbe1}";
            version = "1.0";
            url = "https://addons.mozilla.org/firefox/downloads/file/4147586/catppuccin_mocha-1.0.xpi";
            sha256 = "04lw5dirdv5636i52gfgyd5l0mkd74qjs2p23mimga3xv8hk1dzl";
          })
        ];
        settings = {
          "{3c078156-979c-498b-8990-85f7987dd929}".settings = builtins.fromJSON (
            builtins.readFile ./sidebery.json
          );
          "newtaboverride@agenedia.com".settings = {
            type = "custom_url";
            url = "https://www.cyperpunk.de/";
          };
        };
      };
    };
  };
}
