{ ... }:
{
  services.nginx = {
    enable = true;
    virtualHosts.localhost = {
      locations."/" = {
        return = "200 '<html><body>It works</body></html>'";
        extraConfig = ''
          default_type text/html;
        '';
      };
      listen = [
        {
          addr = "0.0.0.0";
          port = 80;
        }
      ];
    };
  };

  networking.firewall.allowedTCPPorts = [ 80 ];
}
