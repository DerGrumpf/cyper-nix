{ pkgs, ... }:
let
  domain = "auth.cyperpunk.de";
  port = 8444;
  certDir = "/var/lib/kanidm/tls";
in
{
  environment.persistence."/persist".directories = [
    {
      directory = "/var/lib/kanidm";
      user = "kanidm";
      group = "kanidm";
      mode = "0750";
    }
  ];

  systemd.services.kanidm-selfsigned-cert = {
    description = "Generate self-signed TLS certificate for Kanidm";
    wantedBy = [ "kanidm.service" ];
    before = [ "kanidm.service" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      if [ ! -f ${certDir}/cert.pem ]; then
        mkdir -p ${certDir}
        ${pkgs.openssl}/bin/openssl req -x509 \
          -newkey rsa:4096 \
          -keyout ${certDir}/key.pem \
          -out    ${certDir}/cert.pem \
          -days   3650 \
          -nodes  \
          -subj   "/CN=${domain}"
        chown -R kanidm:kanidm ${certDir}
        chmod 750 ${certDir}
        chmod 640 ${certDir}/cert.pem ${certDir}/key.pem
      fi
    '';
  };

  services.kanidm = {
    package = pkgs.kanidm_1_10;

    server = {
      enable = true;
      settings = {
        inherit domain;
        origin = "https://${domain}";

        tls_chain = "${certDir}/cert.pem";
        tls_key = "${certDir}/key.pem";

        bindaddress = "0.0.0.0:${toString port}";

        log_level = "info";

        online_backup = {
          versions = 7;
          path = "/var/lib/kanidm/backups";
          schedule = "00 22 * * *";
        };
      };
    };

    client = {
      enable = true;
      settings.uri = "https://${domain}";
    };
  };

  networking.firewall.allowedTCPPorts = [ port ];
}
