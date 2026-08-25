{
  config,
  inputs,
  primaryUser,
  ...
}:
{
  imports = [ inputs.nixos-mailserver.nixosModules.mailserver ];

  sops.secrets."mail/${primaryUser}" = {
    mode = "0440";
  };

  security.acme = {
    acceptTerms = true;
    defaults.email = "phil.keier@hotmail.com";
  };

  networking.firewall.allowedTCPPorts = [ 80 ];

  services.nginx = {
    enable = true;
    virtualHosts."mail.cyperpunk.de".enableACME = true;
  };

  systemd = {
    services.postfix.serviceConfig.BindPaths = [
      "/run/dovecot2:/var/lib/postfix/queue/private/dovecot2"
    ];

    tmpfiles.rules = [
      "d /storage/internal/mail/dkim 0770 virtualMail rspamd -"
    ];
  };

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
    };
  };
}
