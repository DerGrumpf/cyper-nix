{ config, hostName, ... }:
{
  sops.secrets."network/wireguard/${hostName}" = {
    mode = "0400";
  };

  networking = {
    wireguard.interfaces.wg0 = {
      privateKeyFile = config.sops.secrets."network/wireguard/${hostName}".path;
      mtu = 1380;
    };
    firewall.allowedUDPPorts = [ 51820 ];
  };

}
