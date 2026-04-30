{ config, ... }:
let
  domain = "cyperpunk.de";
  synapseUrl = "http://100.109.179.25:8008";
in
{
  sops.secrets.livekit_key = { };

  services.lk-jwt-service = {
    enable = true;
    keyFile = config.sops.secrets.livekit_key.path;
    livekitUrl = "wss://cyperpunk.de/livekit/sfu";
  };

  systemd.services.lk-jwt-service.environment = {
    LIVEKIT_FULL_ACCESS_HOMESERVERS = domain;
    MATRIX_BASE_URL = synapseUrl;
  };
}
