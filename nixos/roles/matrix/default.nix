{
  ...
}:
{
  imports = [
    ./synapse.nix
    ./lk-jwt.nix
    ./livekit.nix
  ];

  #networking.firewall = {
  #  allowedTCPPorts = [
  #    8008 # Matrix Synapse
  #    8009 # Cinny
  #    8010 # Element
  #    8011 # Synapse Admin
  #    8012 # FluffyChat
  #    8448 # Matrix federation
  #    3478 # TURN (coturn)
  #  ];
  #  allowedUDPPorts = [
  #    3478 # TURN (coturn)
  #  ];
  #  allowedUDPPortRanges = [
  #    {
  #      from = 49152;
  #      to = 65535; # TURN relay ports (coturn)
  #    }
  #  ];
  #};
}
