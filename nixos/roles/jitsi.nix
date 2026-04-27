{
  pkgs,
  ...
}:

let
  domain = "jitsi.cyperpunk.de";
in
{
  nixpkgs.config.permittedInsecurePackages = [
    "jitsi-meet-1.0.8792"
  ];

  services.jitsi-meet = {
    enable = true;
    hostName = domain;

    config = {
      enableWelcomePage = true;
      prejoinPageEnabled = true;
      enableInsecureRoomNameWarning = true;
      disableAudioLevels = false;
      enableLayerSuspension = true;
      p2p.enabled = true;
      analytics.disabled = true;
    };

    interfaceConfig = {
      SHOW_JITSI_WATERMARK = false;
      SHOW_WATERMARK_FOR_GUESTS = false;
      DEFAULT_REMOTE_DISPLAY_NAME = "Meeting @ Virtual";
      TOOLBAR_BUTTONS = [
        "microphone"
        "camera"
        "desktop"
        "fullscreen"
        "fodeviceselection"
        "hangup"
        "profile"
        "chat"
        "recording"
        "livestreaming"
        "etherpad"
        "sharedvideo"
        "settings"
        "raisehand"
        "videoquality"
        "filmstrip"
        "invite"
        "feedback"
        "stats"
        "shortcuts"
        "tileview"
        "select-background"
        "mute-everyone"
        "security"
      ];
    };

    # Enable Jibri for recording/livestreaming support
    jibri = {
      enable = true;
    };

    # Enable Jigasi for SIP/telephony support (optional, comment out if not needed)
    # jigasi.enable = true;

    nginx.enable = true;
    prosody.enable = true;
  };

  # Jitsi Videobridge — handles the actual media routing
  services.jitsi-videobridge = {
    enable = true;
    openFirewall = true;

    config = {
      videobridge = {
        ice.udp.port = 10000;
        apis.rest.enabled = true;
      };
    };
  };

  networking.firewall = {
    allowedTCPPorts = [
      5222 # XMPP client (Prosody)
      5269 # XMPP federation (Prosody)
    ];
    allowedUDPPorts = [
      10000 # Jitsi Videobridge RTP media
    ];
    allowedUDPPortRanges = [
      {
        from = 49152;
        to = 65535;
      } # WebRTC ephemeral ports
    ];
  };

  # Prosody needs this for XMPP
  networking.extraHosts = ''
    127.0.0.1 ${domain}
    127.0.0.1 auth.${domain}
    127.0.0.1 focus.${domain}
    127.0.0.1 jitsi-videobridge.${domain}
  '';

  # Jibri requires Chromium for recording
  environment.systemPackages = with pkgs; [
    chromium
    ffmpeg
  ];

  # ALSA loopback device — required by Jibri for audio capture during recording
  boot.kernelModules = [ "snd-aloop" ];
}
