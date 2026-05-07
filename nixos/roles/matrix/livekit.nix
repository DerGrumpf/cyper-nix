{ config, ... }:
{
  sops.secrets.livekit_key_file = { };

  services.livekit = {
    enable = true;
    openFirewall = true;
    settings.room.auto_create = false;
    keyFile = config.sops.secrets.livekit_key_file.path;
  };

  services.lk-jwt-service = {
    enable = true;
    livekitUrl = "wss://cyperpunk.de/livekit/sfu";
    keyFile = config.sops.secrets.livekit_key_file.path;
  };

  systemd.services.lk-jwt-service.environment.LIVEKIT_FULL_ACCESS_HOMESERVERS = "cyperpunk.de";
}
