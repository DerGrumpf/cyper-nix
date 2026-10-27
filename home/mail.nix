{
  config,
  lib,
  pkgs,
  ...
}:
let
  name = "Phil Keier";
  oama = pkgs.oama.override { withGpg = true; };

  notifyMail = pkgs.writeShellScript "notify-mail" ''
    box="$3"
    [ "$box" = "INBOX" ] && box="Inbox"

    dir="$HOME/Mails/$1/$box/cur"
    state="$HOME/.local/state/notify-mail/$1-$(echo "$box" | ${pkgs.coreutils}/bin/tr / _)"
    ${pkgs.coreutils}/bin/mkdir -p "$(${pkgs.coreutils}/bin/dirname "$state")"

    exec 9> "$state.lock"
    ${pkgs.util-linux}/bin/flock 9

    first=0
    if [ ! -e "$state" ]; then
      first=1
      : > "$state"
    fi

    esc() { ${pkgs.gnused}/bin/sed -e 's/&/\&amp;/g' -e 's/</\&lt;/g' -e 's/>/\&gt;/g'; }

    for path in "$dir"/*; do
      [ -e "$path" ] || continue
      name=$(${pkgs.coreutils}/bin/basename "$path")
      id="''${name%%:*}"

      ${pkgs.gnugrep}/bin/grep -qxF "$id" "$state" && continue
      echo "$id" >> "$state"

      [ "$first" = 1 ] && continue
      case "$name" in *:2,*S*) continue ;; esac

      from=$(${pkgs.mblaze}/bin/mhdr -d -h from "$path" | esc)
      subject=$(${pkgs.mblaze}/bin/mhdr -d -h subject "$path" | esc)

      ${pkgs.libnotify}/bin/notify-send "$2" "$from
    $subject"
    done
  '';
in
{

  home = {
    packages = [ oama ];
    persistence."/persist".directories = [
      ".local/state/oama"
      ".local/state/notify-mail"
      "Mails"
    ];
  };

  # Using Thunderbirds key out of poor lazyness
  xdg.configFile."oama/config.yaml".text = ''
    encryption:
      tag: GPG
      contents: 5F136D46FD9B4AD6

    services:
      microsoft:
        client_id: 9e5f94bc-e8a4-4e73-b8be-63364c29d753
  '';

  sops.secrets = {
    "mail/gmail" = { };
    "mail/hbk" = { };
    "mail/tubs" = { };
    "mail/cyperpunk" = { };
  };

  accounts.email = {
    maildirBasePath = "Mails";
    accounts = {
      hotmail = {
        address = "phil.keier@hotmail.com";
        realName = name;
        flavor = "outlook.office365.com";
        passwordCommand = "${oama}/bin/oama access phil.keier@hotmail.com";

        maildir.path = "Hotmail";

        imap.authentication = "xoauth2";

        smtp = {
          host = lib.mkForce "smtp-mail.outlook.com";
          authentication = "xoauth2";
        };

        aerc = {
          enable = true;
          smtpAuth = "xoauth2";
          extraAccounts = {
            source = "maildir://~/Mails/Hotmail";
            check-mail-cmd = "mbsync hotmail";
            check-mail = "5m";
            check-mail-timeout = "400s";
          };
        };

        mbsync = {
          enable = true;
          create = "both";
          expunge = "both";
          remove = "both";
          extraConfig.account.AuthMechs = "XOAUTH2";
        };

        imapnotify = {
          enable = true;
          onNotify = "mbsync hotmail";
          onNotifyPost = "${notifyMail} Hotmail phil.keier@hotmail.com %s";
          boxes = [
            "INBOX"
            "Inbox/MeWi"
          ];
          extraConfig.xoAuth2 = true;
        };
      };

      gmail = {
        address = "phil.keier@gmail.com";
        realName = name;
        flavor = "gmail.com";
        passwordCommand = "cat ${config.sops.secrets."mail/gmail".path}";

        maildir.path = "GMail";

        aerc = {
          enable = true;
          extraAccounts = {
            source = "maildir://~/Mails/GMail";
            check-mail-cmd = "mbsync gmail";
            check-mail = "5m";
            check-mail-timeout = "400s";
            postpone = "[Gmail]/Entwürfe";
            copy-to = "";
          };
        };

        mbsync = {
          enable = true;
          create = "both";
          expunge = "both";
          remove = "both";
          patterns = [
            "*"
            "![Gmail]/Alle*"
          ]; # Exclude the "Alle Nachrichten" box, since it doubles mails
          extraConfig.account.AuthMechs = "LOGIN";
        };

        imapnotify = {
          enable = true;
          onNotify = "mbsync gmail";
          onNotifyPost = "${notifyMail} GMail phil.keier@gmail.com %s";
          boxes = [ "INBOX" ];
        };
      };

      hbk = {
        primary = true;
        address = "p.keier@hbk-bs.de";
        userName = "id362918@hbk-bs.local";
        realName = name;
        passwordCommand = "cat ${config.sops.secrets."mail/hbk".path}";
        maildir.path = "HbK";

        imap = {
          host = "imap.sonia.de";
          port = 993;
        };

        smtp = {
          host = "smtp.sonia.de";
          port = 587;
          authentication = "login";
          tls.useStartTls = true;
        };

        aerc = {
          enable = true;
          smtpAuth = "login";
          extraAccounts = {
            source = "maildir://~/Mails/HbK";
            check-mail-cmd = "mbsync hbk";
            check-mail = "5m";
            postpone = "Entwürfe";
          };
        };

        mbsync = {
          enable = true;
          create = "both";
          expunge = "both";
          remove = "both";
          extraConfig.account = {
            AuthMechs = "LOGIN";
            PipelineDepth = 16;
          };
        };

        imapnotify = {
          enable = true;
          onNotify = "mbsync hbk";
          onNotifyPost = "${notifyMail} HbK p.keier@hbk-bs.de %s";
          boxes = [ "INBOX" ];
        };
      };

      tubs = {
        address = "p.keier@tu-bs.de";
        userName = "ad\\y0098084"; # Nix Escaping \ (see nix types)
        realName = name;
        passwordCommand = "cat ${config.sops.secrets."mail/tubs".path}";
        maildir.path = "TUBS";

        imap = {
          host = "mail.tu-braunschweig.de";
          port = 993;
        };

        smtp = {
          host = "mail.tu-braunschweig.de";
          port = 587;
          authentication = "login";
          tls.useStartTls = true;
        };

        aerc = {
          enable = true;
          smtpAuth = "login";
          extraAccounts = {
            source = "maildir://~/Mails/TUBS";
            check-mail-cmd = "mbsync tubs";
            check-mail = "5m";
            copy-to = "Gesendete Elemente";
            postpone = "Entwürfe";
          };
        };

        mbsync = {
          enable = true;
          create = "both";
          expunge = "both";
          remove = "both";
          extraConfig.account = {
            AuthMechs = "LOGIN";
            User = "ad\\\\y0098084"; # gets stripped down to ad\y... at the end (Hate it)
          };
        };

        imapnotify = {
          enable = true;
          onNotify = "mbsync tubs";
          onNotifyPost = "${notifyMail} TUBS p.keier@tu-bs.de %s";
          boxes = [ "INBOX" ];
        };
      };

      cyperpunk = {
        address = "phil@cyperpunk.de";
        userName = "phil@cyperpunk.de";
        realName = name;
        passwordCommand = "cat ${config.sops.secrets."mail/cyperpunk".path}";
        maildir.path = "Cyperpunk";

        imap = {
          host = "mail.cyperpunk.de";
          port = 993;
        };

        smtp = {
          host = "mail.cyperpunk.de";
          port = 465;
        };

        aerc = {
          enable = true;
          extraAccounts = {
            source = "maildir://~/Mails/Cyperpunk";
            check-mail-cmd = "mbsync cyperpunk";
            check-mail = "5m";
          };
        };

        mbsync = {
          enable = true;
          create = "both";
          expunge = "both";
          remove = "both";
          extraConfig.account.AuthMechs = "LOGIN";
        };

        imapnotify = {
          enable = true;
          onNotify = "mbsync cyperpunk";
          onNotifyPost = "${notifyMail} Cyperpunk phil@cyperpunk.de %s";
          boxes = [ "INBOX" ];
        };
      };
    };
  };

  programs = {
    # TUI Client for Mails
    aerc = {
      enable = true;
      extraConfig = {
        general.unsafe-accounts-conf = true;

        filters = {
          "text/plain" = "${pkgs.coreutils}/bin/cat";
          "text/html" = "${pkgs.w3m}/bin/w3m -dump -I UTF-8 -T text/html";
        };

        openers = {
          "application/pdf" = "kitty tdf {}";
          "application/octet-stream" = "kitty tdf {}";
          "image/png" = "kitty kitten icat --hold {}";
          "image/jpeg" = "kitty kitten icat --hold {}";
          "image/gif" = "kitty kitten icat --hold {}";
          "image/webp" = "kitty kitten icat --hold {}";
        };
      };
    };

    # Mailboxer syncing Mails offline, instead of IMAP Cache Header
    mbsync = {
      enable = true;
      package = pkgs.isync.override { withCyrusSaslXoauth2 = true; };
    };
  };

  services.imapnotify = {
    enable = true;
    path = with pkgs; [
      coreutils
      libnotify
    ];
  };
}
