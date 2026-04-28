{ pkgs, ... }:
let
  keyFile = "/run/livekit/livekit.key";
  domain = "cyperpunk.de";
  synapseUrl = "http://100.109.179.25:8008";
in
{
  services = {
    livekit = {
      enable = true;
      openFirewall = true;
      inherit keyFile;
      settings = {
        rtc = {
          tcp_port = 7881;
          udp_port = 7882;
          port_range_start = 50000;
          port_range_end = 60000;
          use_external_ip = true;
          node_ip = "178.254.8.35";
        };
        room = {
          auto_create = false;
          enabled_codecs = [
            { mime = "video/VP8"; }
            { mime = "video/VP9"; }
            { mime = "video/H264"; }
            { mime = "audio/opus"; }
          ];
          enable_remote_unmute = true;
        };
      };
    };

    lk-jwt-service = {
      enable = true;
      #livekitUrl = "wss://cyperpunk.de/livekit/sfu";
      inherit keyFile;
      livekitUrl = "wss://127.0.0.1:7880";
    };
  };

  systemd.services = {
    livekit-key = {
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

    lk-jwt-service.environment = {
      LIVEKIT_FULL_ACCESS_HOMESERVERS = domain;
      MATRIX_BASE_URL = synapseUrl;
    };
  };
}
