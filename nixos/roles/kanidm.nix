# FIRST TIME SETUP (after nixos-rebuild switch on cyper-controller):
#   $ sudo kanidmd recover-account admin
#   $ sudo kanidmd recover-account idm_admin
#
{ pkgs, ... }:
let
  domain = "auth.cyperpunk.de";
  port = 8443;
  certDir = "/var/lib/kanidm/tls";
in
{
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
    enableServer = true;

    serverSettings = {
      inherit domain;
      origin = "https://${domain}";

      tls_chain = "${certDir}/cert.pem";
      tls_key = "${certDir}/key.pem";

      bindaddress = "0.0.0.0:${toString port}";

      db_path = "/var/lib/kanidm/kanidm.db";
      log_level = "info";
    };

    enableClient = true;
    clientSettings.uri = "https://${domain}";
  };

  networking.firewall.allowedTCPPorts = [ port ];
}
