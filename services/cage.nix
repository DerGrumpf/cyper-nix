{ pkgs, ... }:
let
  kiosk-url = "https://www.cyperpunk.de";
  kiosk-user = "kiosk";
  kiosk-program =
    "${pkgs.chromium}/bin/chromium "
    + "--kiosk "
    + "--app=${kiosk-url} "
    + "--noerrdialogs "
    + "--disable-infobars "
    + "--no-first-run "
    + "--disable-translate "
    + "--disable-features=TranslateUI "
    + "--autoplay-policy=no-user-gesture-required "
    + "--enable-features=WebUIDarkMode "
    + "--force-dark-mode ";
in
{
  environment = {
    systemPackages = [
      pkgs.cage
      pkgs.chromium
    ];

    variables = {
      XKB_DEFAULT_LAYOUT = "de";
      XKB_DEFAULT_VARIANT = "mac";
      XKB_DEFAULT_OPTIONS = "terminate:ctrl_alt_bksp";
    };

    loginShellInit = ''
      if [ "$(tty)" = "/dev/tty1" ] && [ "$USER" = "${kiosk-user}" ]; then
        export XDG_CONFIG_HOME=/home/${kiosk-user}/.config
        export XDG_CACHE_HOME=/home/${kiosk-user}/.cache
        exec ${pkgs.cage}/bin/cage -s -- ${kiosk-program}
      fi
    '';
  };

  services.getty.autologinUser = kiosk-user;

  users.users.${kiosk-user} = {
    isNormalUser = true;
    home = "/home/${kiosk-user}";
    createHome = true;
  };

}
