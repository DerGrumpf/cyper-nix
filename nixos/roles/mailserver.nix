{
  config,
  inputs,
  primaryUser,
  pkgs,
  ...
}:
{
  imports = [ inputs.nixos-mailserver.nixosModules.mailserver ];

  sops.secrets = {
    "mail/${primaryUser}" = {
      mode = "0440";
    };
    "mail/mastodon" = {
      mode = "0440";
    };
  };

  security.acme = {
    acceptTerms = true;
    defaults.email = "phil.keier@hotmail.com";
  };

  networking.firewall.allowedTCPPorts = [ 80 ];

  services = {
    nginx = {
      enable = true;
      virtualHosts."mail.cyperpunk.de".enableACME = true;
    };

    postfix.settings.main = {
      relayhost = [ "[10.10.0.1]:2525" ];
      smtp_bind_address = "10.10.0.2";
    };
  };

  systemd = {
    tmpfiles.rules = [
      "d /storage/internal/mail/dkim 0770 virtualMail rspamd -"
    ];
    services.postfix-tlspol.serviceConfig.RestrictAddressFamilies = [ "AF_UNIX" ];
  };

  system.activationScripts.mailDkimAcl = ''
    ${pkgs.acl}/bin/setfacl -m g:rspamd:x /storage/internal/mail
  '';

  mailserver = {
    enable = true;
    stateVersion = 5;
    fqdn = "mail.cyperpunk.de";
    domains = [ "cyperpunk.de" ];
    storage.path = "/storage/internal/mail";
    dkim.keyDirectory = "/storage/internal/mail/dkim";
    x509.useACMEHost = config.mailserver.fqdn;
    localDnsResolver = false;
    accounts = {
      "${primaryUser}@cyperpunk.de" = {
        hashedPasswordFile = config.sops.secrets."mail/${primaryUser}".path;
        aliases = [ "postmaster@cyperpunk.de" ];
      };
      "mastodon@cyperpunk.de" = {
        hashedPasswordFile = config.sops.secrets."mail/mastodon".path;
      };
    };
  };
}
