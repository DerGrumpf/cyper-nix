{ ... }:
{
  imports = [
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

    firewall.allowedTCPPorts = [
      80
      443
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
