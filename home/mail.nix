{
  config,
  lib,
  pkgs,
  ...
}:
let
  name = "Phil Keier";
  oama = pkgs.oama.override { withGpg = true; };
in
{

  home = {
    packages = [ oama ];
    persistence."/persist".directories = [
      ".local/state/oama"
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

  accounts.email.accounts = {
    hotmail = {
      address = "phil.keier@hotmail.com";
      realName = name;
      flavor = "outlook.office365.com";
      passwordCommand = "${oama}/bin/oama access phil.keier@hotmail.com";

      imap.authentication = "xoauth2";

      smtp = {
        host = lib.mkForce "smtp-mail.outlook.com";
        authentication = "xoauth2";
      };
    };

    gmail = {
      address = "phil.keier@gmail.com";
      realName = name;
      flavor = "gmail.com";
      passwordCommand = "cat ${config.sops.secrets."mail/gmail".path}";
    };

    hbk = {
      primary = true;
      address = "p.keier@hbk-bs.de";
      userName = "id362918@hbk-bs.local";
      realName = name;
      passwordCommand = "cat ${config.sops.secrets."mail/hbk".path}";

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
    };

    tubs = {
      address = "p.keier@tu-bs.de";
      userName = "ad\\y0098084"; # Nix Escaping \ (see nix types)
      realName = name;
      passwordCommand = "cat ${config.sops.secrets."mail/tubs".path}";

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
    };

    cyperpunk = {
      address = "phil@cyperpunk.de";
      userName = "phil@cyperpunk.de";
      realName = name;
      passwordCommand = "cat ${config.sops.secrets."mail/cyperpunk".path}";

      imap = {
        host = "mail.cyperpunk.de";
        port = 993;
      };

      smtp = {
        host = "mail.cyperpunk.de";
        port = 465;
      };
    };
  };
}
