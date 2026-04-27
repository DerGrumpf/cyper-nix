{ ... }:
{
  imports = [
    ./hardware-configuration.nix
    ../../nixos/roles/nginx.nix
    ../../nixos/roles/livekit.nix
    ../../nixos/roles/jitsi.nix
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
    };
    defaultGateway = "178.254.8.1";
    nameservers = [
      "178.254.16.151"
      "178.254.16.141"
    ];

    firewall.allowedTCPPorts = [
      80
      443
    ];

  };

  system.stateVersion = "26.05";
}
