{ pkgs, ... }:

let
  keyFile = "/run/livekit/livekit.key";
  domain = "cyperpunk.de";
  synapseUrl = "http://100.109.179.25:8008"; # Tailscale IP of cyper-controller
in
{
  services.livekit = {
    enable = true;
    openFirewall = true;
    inherit keyFile;
    settings.room.auto_create = false;
  };

  services.lk-jwt-service = {
    enable = true;
    livekitUrl = "wss://${domain}/livekit/sfu";
    inherit keyFile;
  };

  systemd.services.livekit-key = {
    before = [
      "lk-jwt-service.service"
      "livekit.service"
    ];
    wantedBy = [ "multi-user.target" ];
    path = with pkgs; [
      livekit
      coreutils
      gawk
    ];
    script = ''
      mkdir -p /run/livekit
      echo "lk-jwt-service: $(livekit-server generate-keys | tail -1 | awk '{print $3}')" > "${keyFile}"
    '';
    serviceConfig.Type = "oneshot";
    unitConfig.ConditionPathExists = "!${keyFile}";
  };

  systemd.services.lk-jwt-service.environment = {
    LIVEKIT_FULL_ACCESS_HOMESERVERS = domain;
    MATRIX_BASE_URL = synapseUrl; # tells lk-jwt-service where to validate tokens
  };
}
