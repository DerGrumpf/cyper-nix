{
  lib,
  pkgs,
  primaryUser,
  ...
}:
{
  environment.etc = {
    "greetd/background.png".source = ../assets/wallpapers/lucy_with_cat.png;
    "greetd/environments".text = ''
      Hyprland
      fish
    '';
  };

  programs.regreet = {
    enable = true;
    cageArgs = [
      "-s"
      "-m"
      "last"
    ];
    theme = {
      name = "catppuccin-mocha-standard-sky-dark";
      package = pkgs.catppuccin-gtk;
    };
    cursorTheme = {
      name = "catppuccin-mocha-sapphire-cursors";
      package = pkgs.catppuccin-cursors.mochaSapphire;
    };
    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.papirus-icon-theme;
    };
    font = {
      name = "FiraCode Nerd Font Propo";
      size = 12;
      package = pkgs.nerd-fonts.fira-code;
    };
    settings = {
      background = {
        path = "/etc/greetd/background.png";
        fit = "Fill";
      };
      GTK = {
        application_prefer_dark_theme = true;
        cursor_theme_name = lib.mkForce "catppuccin-mocha-sapphire-cursors";
        font_name = lib.mkForce "FiraCode Nerd Font Propo 12";
        icon_theme_name = lib.mkForce "Papirus-Dark";
        theme_name = lib.mkForce "catppuccin-mocha-standard-sky-dark";
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
        command = "${pkgs.greetd.regreet}/bin/regreet";
        user = "greeter";
      };
      initial_session = {
        command = "start-hyprland";
        user = primaryUser;
      };
    };
  };
}
