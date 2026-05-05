{ config, lib, ... }:
let
  domain = "cyperpunk.de";
  synapseUrl = "http://localhost:8008";
in
{
  sops.secrets.livekit_key_jwt = { };

  networking.firewall.allowedTCPPorts = [ 18080 ];

  services.lk-jwt-service = {
    enable = true;
    keyFile = config.sops.secrets.livekit_key_jwt.path;
    livekitUrl = "wss://cyperpunk.de/livekit/sfu";
  };

  systemd.services.lk-jwt-service = {
    environment = {
      LIVEKIT_FULL_ACCESS_HOMESERVERS = domain;
      MATRIX_BASE_URL = synapseUrl;
      LIVEKIT_JWT_BIND = lib.mkForce ":18080";
      LIVEKIT_INSECURE_SKIP_VERIFY_TLS = "YES_I_KNOW_WHAT_I_AM_DOING";
    };
  };
}
