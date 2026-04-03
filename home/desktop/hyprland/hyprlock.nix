{ ... }:

{

  # Hyprlock configuration
  programs.hyprlock = {
    enable = true;
    settings = {

      "$accent" = "$mauve";
      "$accentAlpha" = "$mauveAlpha";
      "$font" = "FiraCode Nerd Font";

      general = {
        disable_loading_bar = true;
        hide_cursor = true;
      };

      background = [
        {
          path = "~/Pictures/Wallpapers/lucy_with_cat.png";
          blur_passes = 1;
          blur_size = 5;
        }
      ];

      label = [
        # TIME
        {
          monitor = "";
          text = "$TIME";
          color = "$peach";
          font_size = 90;
          font_family = "$font";
          position = "0, -100";
          halign = "center";
          valign = "top";
        }

        # DATE
        {
          monitor = "";
          text = ''cmd[update:43200000]  date +"%A, %d %B %Y"'';
          color = "$peach";
          font_size = 25;
          font_family = "$font";
          position = "0, 100";
          halign = "center";
          valign = "bottom";
        }

        # Message
        {
          monitor = "";
          text = "Waiting for you...";
          color = "$peach";
          font_size = 20;
          font_family = "$font";
          position = "0, 200";
          halign = "center";
          valign = "bottom";
        }

        # Weather
        {
          monitor = "";
          text = ''cmd[update:60000] curl -s "wttr.in/52.281311,10.527029?format=1"'';
          color = "$peach";
          font_size = 20;
          font_family = "$font";
          position = "0, 50";
          halign = "center";
          valign = "bottom";
        }
      ];

      # INPUT FIELD
      input-field = {
        monitor = "";
        size = "300, 60";
        outline_thickness = 4;
        dots_size = 0.2;
        dots_spacing = 0.2;
        dots_center = "true";
        outer_color = "$red";
        inner_color = "$surface0";
        font_color = "$text";
        fade_on_empty = false;
        placeholder_text = ''<span foreground="##$textAlpha"><i>󰌾 Logged in as </i><span foreground="##$accentAlpha">$USER</span></span>'';
        hide_input = false;
        check_color = "$accent";
        fail_color = "$red";
        fail_text = "<i>$FAIL <b>($ATTEMPTS)</b></i>";
        capslock_color = "$yellow";
        position = "0, -150";
        halign = "center";
        valign = "center";
      };

      image = {
        monitor = "";
        path = "~/.config/hypr/avatar/avatar.png";
        size = 300;
        border_color = "$teal";
        position = "0, 75";
        halign = "center";
        valign = "center";
      };
    };
  };

}
