{ ... }:
{
  imports = [
    ./disko.nix
    ./hardware-configuration.nix
    ../../nixos/roles/nginx.nix
    #    ../../nixos/roles/jitsi.nix
    ../../nixos/roles/matrix
  ];

  networking = {
    hostName = "cyper-proxy";
    useDHCP = false;
    interfaces.ens3 = {
      ipv4.addresses = [
        {
          address = "178.254.8.35";
          prefixLength = 23;
        }
      ];
      ipv6.addresses = [
        {
          address = "2a00:6800:3:1094::1";
          prefixLength = 64;
        }
      ];
    };
    defaultGateway = "178.254.8.1";

    defaultGateway6 = {
      address = "2a00:6800:3::1";
      interface = "ens3";
    };

    nameservers = [
      "178.254.16.151"
      "178.254.16.141"
    ];

    wireguard.interfaces.wg0 = {
      ips = [ "10.10.0.1/24" ];
      listenPort = 51820;
      peers = [
        {
          publicKey = "EvML4de3CReNW8aF+lJAsPZ+p6FICOyjCsAZJBwIwX8=";
          allowedIPs = [ "10.10.0.2/32" ];
        }
        {
          publicKey = "WkY45tGnNZQuJTf1MPN6I92spxHts/kpzXRSZE9se2c=";
          allowedIPs = [ "10.10.0.3/32" ];
        }
        {
          publicKey = "oAstNd7Wxpj2PqSyS87q+8y8WtaLK7hZ5Ytfncml9EM=";
          allowedIPs = [ "10.10.0.40/32" ];
        }
        {
          publicKey = "GrFH3I5QqjRij7Jl+eOL6Ou6zK6MtH5/kAsA5AmGckM=";
          allowedIPs = [ "10.10.0.30/32" ];
        }
        {
          publicKey = "IddGAijZVCVxGj/aMasjfroIy9r8Owar4MO9xfvNNBY=";
          allowedIPs = [ "10.10.0.31/32" ];
        }
      ];
    };

    firewall.allowedTCPPorts = [
      80
      443
      51820
    ];

    hosts = {
      "178.254.8.35" = [
        "cyperpunk.de"
        "matrix.cyperpunk.de"
      ];

      "2a00:6800:3:1094::1" = [
        "cyperpunk.de"
        "matrix.cyperpunk.de"
      ];
    };

  };

  system.stateVersion = "26.05";
}
