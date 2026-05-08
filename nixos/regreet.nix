{
  lib,
  pkgs,
  ...
}:
{
  environment.etc = {
    "greetd/background.png".source = ../assets/wallpapers/lucy_with_cat.png;
    "greetd/environments".text = ''
      Hyprland
      niri-session
      fish
    '';
  };

  programs.regreet = {
    enable = false;

    cageArgs = [
      "-s"
      "-m"
      "last"
    ];

    settings = {

      background = {
        path = "/etc/greetd/background.png";
        fit = "Fill";
      };

      GTK = {
        application_prefer_dark_theme = true;
        cursor_theme_name = lib.mkForce "catppuccin-mocha-dark-cursors";
        font_name = lib.mkForce "FiraCode Nerd Font Propo 12";
        icon_theme_name = lib.mkForce "Papirus-Dark";
        theme_name = lib.mkForce "catppuccin-mocha-standard-mauve-dark";
      };

      commands = {
        reboot = [
          "systemctl"
          "reboot"
        ];
        poweroff = [
          "systemctl"
          "poweroff"
        ];
        x11_prefix = [
          "startx"
          "/usr/bin/env"
        ];
      };

      appearance = {
        greeting_msg = "Hey there!";
      };

      widget.clock = {
        format = "%A %d.%m.%Y %T";
        resolution = "500ms";
        timezone = "Europe/Berlin";
        label_width = 150;
      };
    };
  };

  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.tuigreet}/bin/tuigreet --cmd start-hyprland";
        user = "greeter";
      };
      initial_session = {
        command = "Hyprland";
        user = "phil";
      };
    };
  };
}
