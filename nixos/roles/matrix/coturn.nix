{
  config,
  ...
}:
{
  networking.firewall = {
    allowedTCPPorts = [
      3478 # TURN (coturn)
    ];
    allowedUDPPorts = [
      3478 # TURN (coturn)
    ];
    allowedUDPPortRanges = [
      {
        from = 49152;
        to = 65535; # TURN relay ports (coturn)
      }
    ];
  };

  sops.secrets.matrix_turn_secret = {
    owner = "matrix-synapse";
    group = "matrix-synapse";
  };

  services.coturn = {
    enable = true;
    no-cli = true;
    no-tcp-relay = true;
    min-port = 49152;
    max-port = 65535;
    use-auth-secret = true;
    static-auth-secret-file = config.sops.secrets.matrix_turn_secret.path;
    realm = "turn.cyperpunk.de";
    extraConfig = ''
      no-multicast-peers
    '';
  };
}
