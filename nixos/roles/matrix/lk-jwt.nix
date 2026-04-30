{ config, lib, ... }:
let
  domain = "cyperpunk.de";
  synapseUrl = "http://100.109.179.25:8008";
in
{
  sops.secrets.livekit_key_jwt = { };

  networking.firewall.allowedTCPPorts = [ 18080 ];

  services.lk-jwt-service = {
    enable = true;
    keyFile = config.sops.secrets.livekit_key_jwt.path;
    livekitUrl = "ws://100.109.10.91:7880";
  };

  systemd.services.lk-jwt-service = {
    environment = {
      LIVEKIT_FULL_ACCESS_HOMESERVERS = domain;
      MATRIX_BASE_URL = synapseUrl;
      LIVEKIT_JWT_BIND = lib.mkForce ":18080";
    };
  };
}
