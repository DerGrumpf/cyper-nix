{ ... }:
{
  services.filebrowser = {
    enable = true;

    settings = {
      port = 10000;
      address = "0.0.0.0";
      baseURL = "/filebrowser";
      root = "/storage";
    };

    # If you want the port opened in the firewall:
    openFirewall = true;
  };

  #networking.firewall.allowedTCPPorts = [ 8080 ];

}
