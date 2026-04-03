{ ... }:
{
  services.swaync = {
    enable = true;
    settings = {
      positionX = "center";
      positionY = "center";
      layer = "overlay";
      control-center-layer = "top";
      layer-shell = true;
      cssPriority = "user";
      control-center-margin-top = 100;
      control-center-margin-bottom = 200;
      control-center-margin-right = 0;
      control-center-margin-left = 0;
      notification-2fa-action = true;
      notification-inline-replies = false;
      notification-icon-size = 64;
      notification-body-image-height = 100;
      notification-body-image-width = 200;
      widgets = [
        "mpris"
        "volume"
        "inhibitors"
        "title"
        "dnd"
        "notifications"
      ];
      widget-config = {

        mpris = {
          blacklist = [ ];
          autohide = false;
          show-album-art = "always";
          loop-carousel = false;
          image-size = 96;
          image-radius = 12;
        };

        volume = {
          label = "gain";
          show-per-app = false;
          empty-list-label = "Nothin' is playin'";
          expand-button-label = "⤢";
          collaps-button-label = "⤡";
        };

        title = {
          text = "Hollerin'";
          clear-all-button = true;
          button-text = "Sheriff's Pardon";
        };

        dnd = {
          text = "Let'er rest";
        };

        menubar = {
          "menu#power" = {
            label = "Power";
            position = "right";
            animation-type = "slide_down";
            animation-duration = 250;
            actions = [
              {
                label = "Bolt It";
                command = "hyprlock";
              }
              {
                label = "Ride Out";
                command = "hyprctl dispatch exit";
              }
              {
                label = "Circle Back";
                command = "systemctl reboot";
              }
              {
                label = "Bet Down the Horses";
                command = "systemctl poweroff";
              }
            ];
          };

          "buttons#media" = {
            position = "left";
            actions = [
              {
                label = "Play/Pause";
                command = "playerctl play-pause";
              }
              {
                label = "Next";
                command = "playerctl next";
              }
              {
                label = "Previous";
                command = "playerctl previous";
              }
            ];
          };
        };

        notifications = {
          vexpand = true;
        };

      };
    };
  };
}
