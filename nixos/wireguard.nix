{ config, hostName, ... }:
{
  sops.secrets."wireguard/${hostName}" = {
    mode = "0400";
  };

  networking = {
    wireguard.interfaces.wg0 = {
      privateKeyFile = config.sops.secrets."wireguard/${hostName}".path;
    };
    firewall.allowedUDPPorts = [ 51820 ];
  };

}
