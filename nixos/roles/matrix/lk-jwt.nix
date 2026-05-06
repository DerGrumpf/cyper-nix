{ config, ... }:
let
  domain = "cyperpunk.de";
  synapseUrl = "http://127.0.0.1:8008";
  # Internal LiveKit address — JWT service must NOT go through the TLS proxy.
  # Using the public wss:// URL caused token rejection because nginx re-wraps
  # the connection and the JWT service couldn't verify the livekit instance.
  livekitInternalUrl = "ws://127.0.0.1:7880";
in
{
  # Same secret as livekit.nix — both services must share the same key pair
  sops.secrets.livekit_key = { };

  services.lk-jwt-service = {
    enable = true;
    port = 18080;
    keyFile = config.sops.secrets.livekit_key.path;
    livekitUrl = livekitInternalUrl;
  };

  systemd.services.lk-jwt-service.environment = {
    LIVEKIT_FULL_ACCESS_HOMESERVERS = domain;
    MATRIX_BASE_URL = synapseUrl;
  };
}
