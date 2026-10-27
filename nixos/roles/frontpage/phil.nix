{
  lib,
  pkgs,
  config,
  ...
}:
{

  sops.secrets = {
    "services/flame/phil" = { };
    "services/flame/weather" = { };
  };

  services.flame = {
    enable = true;
    port = 15007;
    passwordFile = config.sops.secrets."services/flame/phil".path;
    openFirewall = true;

    customCSS = ''
      body::before {
        content: "";
        position: fixed;
        top: 0;
        left: 0;
        width: 100%;
        height: 100%;
        background: inherit;
        filter: blur(4px) brightness(0.8);
        z-index: -1;

      }

      body {
        --color-background: #242b33;
        --color-primary: #effbff;
        --color-accent: #6ee2ff;
        --spacing-ui: 10px;
        background-color: var(--color-background);
        background-image: url('https://images4.alphacoders.com/836/thumb-1920-83606.jpg');
        background-size: cover;         /* Forces image to fill the screen */
        background-position: center;    /* Keeps the focus in the middle */
        background-repeat: no-repeat;   /* Prevents tiling */
        background-attachment: fixed;   /* Makes it independent of scrolling */
        font-family: Roboto,sans-serif;
        font-size: 14px;
        transition: background-color .3s;
      }
    '';

    settings = {
      weatherApiKeyFile = "/run/credentials/flame.service/flame-weather";
      lat = 52.264149;
      long = 10.52642;
      isCelsius = true;
      isKilometer = true;
      weatherData = "cloud";
      customTitle = "Cyperpunk Home";
      pinAppsByDefault = true;
      pinCategoriesByDefault = true;
      hideHeader = false;
      hideApps = false;
      hideCategories = false;
      hideSearch = false;
      hideDate = false;
      showTime = false;
      useOrdering = "createdAt";
      appsSameTab = true;
      bookmarksSameTab = false;
      searchSameTab = true;
      defaultSearchProvider = "c";
      secondarySearchProvider = "c";
      dockerApps = false;
      dockerHost = "localhost";
      kubernetesApps = false;
      unpinStoppedApps = false;
      useAmericanDate = false;
      disableAutofocus = false;
      greetingsSchema = [
        "Good evening!"
        "Good afternoon!"
        "Good morning!"
        "Good night!"
      ];
      daySchema = [
        "Sunday"
        "Monday"
        "Tuesday"
        "Wednesday"
        "Thursday"
        "Friday"
        "Saturday"
      ];
      monthSchema = [
        "January"
        "February"
        "March"
        "April"
        "May"
        "June"
        "July"
        "August"
        "September"
        "October"
        "November"
        "December"
      ];
      defaultTheme = "#cdd6f4;#74c7ec;#1e1e2e";
    };

    apps = [
      {
        name = "Vaultwarden";
        url = "https://vault.cyperpunk.de";
        icon = "https://img.icons8.com/nolan/64/lock.png";
        description = "Password Manager";
        isPinned = true;
      }
      {
        name = "Search";
        url = "https://search.cyperpunk.de/";
        icon = "https://img.icons8.com/nolan/64/search-more.png";
        description = "SearXNG";
        isPinned = true;
      }
      {
        name = "Forgejo";
        url = "https://git.cyperpunk.de/";
        icon = "https://img.icons8.com/nolan/64/git.png";
        description = "Code Base";
        isPinned = true;
      }
      #{
      #  name = "Storage";
      #  url = "https://file.cyperpunk.de/";
      #  icon = "https://img.icons8.com/nolan/64/cloud-storage.png";
      #  description = "Cloud Storage";
      #  isPinned = true;
      #}
      {
        name = "NAS";
        url = "https://192.168.2.7:5001/#/signin";
        icon = "https://img.icons8.com/pulsar-gradient/48/nas.png";
        description = "Network Backup";
        isPinned = true;
      }
      {
        name = "Zyxel 2";
        url = "http://192.168.2.4/";
        icon = "https://img.icons8.com/nolan/64/networking-manager.png";
        description = "Managed Switch";
        isPinned = true;
      }
      {
        name = "Jupyter";
        url = "https://www.cyperpunk.de/jupyter/";
        icon = "https://img.icons8.com/external-tal-revivo-tritone-tal-revivo/32/external-project-jupyter-a-nonprofit-organization-created-to-open-source-software-logo-tritone-tal-revivo.png";
        description = "Jupyter Stack";
        isPinned = true;
      }
      {
        name = "Learnlytics";
        url = "https://learnlytics.cyperpunk.de:8443";
        icon = "https://img.icons8.com/nolan/64/saving-book.png";
        description = "Learnlytics Platform";
        isPinned = true;
      }
      {
        name = "Adguard";
        url = "http://10.10.0.2:3010/";
        icon = "https://img.icons8.com/nolan/64/dyndns.png";
        description = "DNS";
        isPinned = true;
      }
      {
        name = "Grafana";
        url = "https://www.cyperpunk.de/grafana";
        icon = "https://img.icons8.com/fluency/48/grafana.png";
        description = "Dashboard";
        isPinned = true;
      }
      {
        name = "Unifi";
        url = "https://10.10.0.2:8443";
        icon = "https://img.icons8.com/ios-glyphs/120/ubiquiti.png";
        description = "Freds Home <3";
        isPinned = true;
      }
      {
        name = "LAN Spy";
        url = "http://10.10.0.2:8840/";
        icon = "https://img.icons8.com/nolan/96/flow-chart.png";
        description = "Watch My LAN";
        isPinned = true;
      }
      {
        name = "Zyxel 1";
        url = "http://192.168.2.3/";
        icon = "https://img.icons8.com/nolan/64/networking-manager.png";
        description = "Managed Switch";
        isPinned = true;
      }
      {
        name = "Cinny";
        url = "https://cinny.cyperpunk.de";
        icon = "https://img.icons8.com/nolan/96/twitter.png";
        description = "Matrix Client";
        isPinned = true;
      }
      #{
      #  name = "Element";
      #  url = "https://element.cyperpunk.de";
      #  icon = "https://img.icons8.com/nolan/96/messaging-.png";
      #  description = "Matrix Client";
      #  isPinned = true;
      #}
      {
        name = "Synapse";
        url = "https://cyperpunk.de/admin/";
        icon = "https://img.icons8.com/pulsar-gradient/96/user-settings.png";
        description = "Matrix Admin";
        isPinned = true;
      }
      #{
      #  name = "Fluffy Chat";
      #  url = "https://fluffy.cyperpunk.de";
      #  icon = "https://img.icons8.com/nolan/96/plush.png";
      #  description = "Matrix Client";
      #  isPinned = true;
      #}
      {
        name = "Xono";
        url = "http://51.91.80.158:3000";
        icon = "https://img.icons8.com/fluency/48/grafana.png";
        description = "Xonotic Grafana";
        isPinned = true;
      }
      {
        name = "Mastodon";
        url = "https://mastodon.cyperpunk.de";
        icon = "https://img.icons8.com/nolan/64/mastodon.png";
        description = "The fediverse";
        isPinned = true;
      }
      {
        name = "CyperPrint";
        url = "http://10.10.0.2:5000";
        icon = "https://img.icons8.com/pulsar-gradient/96/octopus.png";
        description = "3D Printer";
        isPinned = true;
      }
      {
        name = "Website";
        url = "https://www.cyperpunk.de/";
        icon = "https://img.icons8.com/nolan/64/document.png";
        description = "Office";
        isPinned = true;
      }
      {
        name = "Element Call";
        url = "https://element-call.cyperpunk.de/";
        icon = "https://img.icons8.com/nolan/96/phone.png";
        description = "Matrix Meet";
        isPinned = true;
      }
      {
        name = "Maubot";
        url = "https://matrix.cyperpunk.de/_matrix/maubot";
        icon = "https://img.icons8.com/nolan/96/bot.png";
        description = "Matrix Bot";
        isPinned = true;
      }
      {
        name = "Authenticator";
        url = "https://auth.cyperpunk.de/";
        icon = "https://img.icons8.com/nolan/96/password.png";
        description = "OpenID";
        isPinned = true;
      }
    ];

    categories = [
      {
        name = "Hosting";
        isPinned = true;
        bookmarks = [
          {
            name = "1Blue";
            url = "https://ksb.1blu.de";
            icon = "https://img.icons8.com/nolan/64/amazon-s3.png";
          }
          {
            name = "Checkdomain";
            url = "https://www.checkdomain.net";
            icon = "https://img.icons8.com/nolan/64/domain.png";
          }
          {
            name = "FreeDNS";
            url = "https://freedns.afraid.org/subdomain/";
            icon = "https://img.icons8.com/nolan/64/dyndns.png";
          }
          {
            name = "GitHub";
            url = "https://github.com/";
            icon = "https://img.icons8.com/nolan/96/github.png";
          }
        ];
      }
      {
        name = "Social Media";
        isPinned = true;
        bookmarks = [
          {
            name = "Instagram";
            url = "https://www.instagram.com/";
            icon = "https://img.icons8.com/nolan/64/instagram-new.png";
          }
          {
            name = "Reddit";
            url = "https://www.reddit.com/";
            icon = "https://img.icons8.com/nolan/64/reddit.png";
          }
          {
            name = "Discord";
            url = "https://discord.com/app";
            icon = "https://img.icons8.com/nolan/64/discord-logo.png";
          }
          {
            name = "Spotify";
            url = "https://open.spotify.com";
            icon = "https://img.icons8.com/nolan/64/spotify.png";
          }
          {
            name = "YouTube";
            url = "https://www.youtube.com/";
            icon = "https://img.icons8.com/nolan/64/youtube-play.png";
          }
        ];
      }
      {
        name = "Banking";
        isPinned = true;
        bookmarks = [
          {
            name = "Volksbank";
            url = "https://www.vbsila.de";
            icon = "https://img.icons8.com/nolan/64/bank-building.png";
          }
          {
            name = "PayPal";
            url = "https://www.paypal.com/myaccount/summary";
            icon = "https://img.icons8.com/nolan/64/paypal.png";
          }
        ];
      }
      {
        name = "Gaming";
        isPinned = true;
        bookmarks = [
          {
            name = "Xonotic";
            url = "https://stats.xonotic.org/";
          }
          {
            name = "World Place";
            url = "https://wplace.live/";
            icon = "https://img.icons8.com/nolan/64/earth-planet.png";
          }
        ];
      }
      {
        name = "AI Tools";
        isPinned = true;
        bookmarks = [
          {
            name = "DeepSeek";
            url = "https://chat.deepseek.com";
            icon = "https://img.icons8.com/nolan/64/deepseek.png";
          }
          {
            name = "ChatGPT";
            url = "https://chatgpt.com/";
            icon = "https://img.icons8.com/nolan/64/chatgpt.png";
          }
          {
            name = "DeepL";
            url = "https://www.deepl.com/en/translator";
            icon = "https://img.icons8.com/nolan/64/google-translate.png";
          }
          {
            name = "Claude";
            url = "https://claude.ai/chat";
            icon = "https://img.icons8.com/pulsar-gradient/48/bard.png";
          }
          {
            name = "Gemini";
            url = "https://gemini.google.com/app";
            icon = "https://img.icons8.com/color/48/bard--v1.png";
          }
        ];
      }
      {
        name = "University";
        isPinned = true;
        bookmarks = [
          {
            name = "StudIP TU BS";
            url = "https://studip.tu-braunschweig.de/";
            icon = "https://img.icons8.com/nolan/64/graduation-cap.png";
          }
          {
            name = "StudIP HBK BS";
            url = "https://studip.hbk-bs.de/";
            icon = "https://img.icons8.com/nolan/64/graduation-cap.png";
          }
          {
            name = "IFN TU BS";
            url = "https://www.tu-braunschweig.de/ifn";
            icon = "https://img.icons8.com/pulsar-gradient/48/radio-waves.png";
          }
          {
            name = "TU Connect";
            url = "https://connect.tu-braunschweig.de/qisserver/pages/cs/sys/portal/hisinoneStartPage.faces";
            icon = "https://img.icons8.com/nolan/64/share-2.png";
          }
        ];
      }
      {
        name = "Environment";
        isPinned = true;
        bookmarks = [
          {
            name = "OpenWeatherMap";
            url = "https://openweathermap.org/city/2945024";
            icon = "https://img.icons8.com/nolan/64/rain.png";
          }
          {
            name = "Maps";
            url = "https://www.google.com/maps";
            icon = "https://img.icons8.com/nolan/64/place-marker.png";
          }
        ];
      }
      {
        name = "Tools";
        isPinned = true;
        bookmarks = [
          {
            name = "Desmos";
            url = "https://www.desmos.com/calculator?lang=de";
            icon = "https://img.icons8.com/nolan/64/wavy-line.png";
          }
          {
            name = "Catppuccin";
            url = "https://catppuccin.com/palette/";
            icon = "https://img.icons8.com/nolan/64/bongo-cat.png";
          }
          {
            name = "Wolfram Alpha";
            url = "https://www.wolframalpha.com/";
            icon = "https://img.icons8.com/nolan/64/alpha.png";
          }
          {
            name = "Polotno";
            url = "https://studio.polotno.com/";
            icon = "https://img.icons8.com/nolan/64/canva-app.png";
          }
        ];
      }
    ];
  };

  systemd.services.flame = {
    preStart = lib.mkAfter ''
      install -m644 ${
        pkgs.writeText "customQueries.json" (
          builtins.toJSON {
            queries = [
              {
                name = "Cyperpunk Search";
                prefix = "c";
                template = "https://search.cyperpunk.de/search?q=";
              }
            ];
          }
        )
      } /var/lib/flame/app/data/customQueries.json
    '';

    serviceConfig = {
      TemporaryFileSystem = [ "/run/secrets:ro" ];
      BindReadOnlyPaths = [ config.sops.secrets."services/flame/weather".path ];
      LoadCredential = [
        "flame-weather:${config.sops.secrets."services/flame/weather".path}"
      ];
    };
  };
}
