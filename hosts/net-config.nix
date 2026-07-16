{ lib, config, ... }:
with lib;
let
  cfg = config.net;
in
{
  options.net = {
    wgIP = mkOption { type = types.str; };
    wgPeers = mkOption {
      type = types.listOf types.attrs;
      default = [
        {
          publicKey = "NjMYaUZO/iPRM/J46qyPPuWYg5oSeAUxjocMs/hYTXs=";
          endpoint = "195.90.219.9:51820";
          allowedIPs = [ "10.10.0.0/24" ];
          persistentKeepalive = 25;
        }
      ];
    };
    ethAddress = mkOption { type = types.str; };
    ethGateway = mkOption {
      type = types.str;
      default = "192.168.2.1";
    };
    ethDNS = mkOption {
      type = types.listOf types.str;
      default = [ "192.168.2.2" ];
    };
    ethIface = mkOption {
      type = types.str;
      default = "enp1s0";
    };
  };

  config = {
    networking = {
      useNetworkd = true;
      useDHCP = false;
      firewall.enable = true;
      wireguard.interfaces.wg0 = {
        ips = [ cfg.wgIP ];
        peers = cfg.wgPeers;
      };
    };

    systemd.network = {
      enable = true;
      networks."10-ethernet" = {
        matchConfig.Name = cfg.ethIface;
        networkConfig = {
          Address = cfg.ethAddress;
          Gateway = cfg.ethGateway;
          DNS = cfg.ethDNS;
          DHCP = "no";
        };
      };
    };
  };
}
