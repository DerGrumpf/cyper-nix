{ pkgs, ... }: {

  # TODO: This need to be tested against the cam and kernel rules need to be refined
  services.udev.extraRules = ''
    ACTION=="add", \
    SUBSYSTEM=="usb", \
    ATTR{idVendor}=="04a9", \
    ATTR{idProduct}=="31ea", \
    RUN+="${pkgs.systemd}/bin/systemctl restart webcam"
  '';

  systemd.services.webcam = {
    enable = true;
    description = "Canon Camera Webcam";
    script = ''
      ${pkgs.gphoto2}/bin/gphoto2 --stdout --capture-movie | \
      ${pkgs.ffmpeg}/bin/ffmpeg \
      -i - \
      -vcodec rawvideo \
      -pix_fmt yuv420p \
      -threads 0 \
      -framerate 30 \
      -f v4l2 \
      /dev/video0
    '';
    wantedBy = [ "multi-user.target" ];
  };
}
