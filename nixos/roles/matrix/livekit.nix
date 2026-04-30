{ config, ... }:
{
  sops.secrets.livekit_key_sfu = { };

  services.livekit = {
    enable = true;
    openFirewall = true;
    keyFile = config.sops.secrets.livekit_key_sfu.path;
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
}
