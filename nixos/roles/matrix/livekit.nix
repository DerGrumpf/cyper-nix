{ config, lib, ... }:
{
  # Shared key file — same secret used by lk-jwt-service (see lk-jwt.nix)
  sops.secrets.livekit_key = { };

  services.livekit = {
    enable = true;
    openFirewall = true;
    keyFile = config.sops.secrets.livekit_key.path;
    settings = {
      rtc = {
        tcp_port = 7881;
        port_range_start = 50000;
        port_range_end = 60000;
        use_external_ip = true;
        node_ip = "178.254.8.35";
      };
      room = {
        # Must be false — rooms are created by the JWT service on demand
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

  networking.firewall = {
    allowedTCPPorts = [ 7881 ];
    # WebRTC media relay — must be open or calls connect then immediately drop
    allowedUDPPortRanges = [
      {
        from = 50000;
        to = 60000;
      }
    ];
  };

  systemd.services.livekit.serviceConfig = {
    PrivateUsers = lib.mkForce false;
    DynamicUser = lib.mkForce false;
    User = "livekit";
    Group = "livekit";
    RestrictAddressFamilies = lib.mkForce [
      "AF_INET"
      "AF_INET6"
      "AF_NETLINK"
      "AF_UNIX"
    ];
    SystemCallFilter = lib.mkForce [ "@system-service" ];
  };

  users = {
    users.livekit = {
      isSystemUser = true;
      group = "livekit";
    };
    groups.livekit = { };
  };
}
