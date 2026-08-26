{
  services.postfix = {
    enable = true;
    settings.main = {
      myhostname = "mail.cyperpunk.de";
      mynetworks_style = "host";
      mynetworks = [
        "10.10.0.0/24"
        "127.0.0.0/8"
      ];
      smtpd_relay_restrictions = [
        "permit_mynetworks"
        "reject_unauth_destination"
      ];
      inet_interfaces = [ "127.0.0.1" ];
    };
    settings.master."10.10.0.1:2525" = {
      type = "inet";
      private = false;
      command = "smtpd";
    };
  };

  networking.firewall.interfaces."wg0".allowedTCPPorts = [ 2525 ];
}
