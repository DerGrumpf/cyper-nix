{ pkgs, ... }: {
  services = {
    yabai = {
      enable = true;
      config = {
        external_bar = "main:40:0";
        menubar_opacity = 1.0;
        mouse_follows_focus = "on";
        focus_follows_mouse = "on";
        display_arrangement_order = "default";

        window_origin_display = "default";
        window_placement = "second_child";
        window_insertion_point = "focused";
        window_zoom_persist = "on";
        window_shadow = "off";
        window_animation_duration = 0.0;
        window_animation_easing = "ease_out_circ";
        window_opacity_duration = 0.0;
        active_window_opacity = 1.0;
        normal_window_opacity = 0.9;
        window_opacity = "off";

        insert_feedback_color = "0xffd75f5f";
        split_ratio = 0.5;
        split_type = "auto";
        auto_balance = "off";
        top_padding = 2;
        bottom_padding = 2;
        left_padding = 2;
        right_padding = 2;
        window_gap = 2;

        layout = "bsp";
        mouse_modifier = "fn";
        mouse_action1 = "move";
        mouse_action2 = "resize";
        mouse_drop_action = "swap";
      };
    };

    #    skhd = {
    #      enable = true;
    #      skhdConfig = ''
    # Application Bindings
    #        cmd - q : open -a kitty
    #        cmd - e : ${pkgs.kitty}/bin/kitty yazi
    #        cmd - o : open -a "Obsidian"
    #        cmd - i : open -a "Floorp" 
    #        cmd - g : open -a "Mail"

    # Window Management (using yabai if installed, otherwise basic macOS)
    #cmd + shift - c : yabai -m window --close || osascript -e 'tell application "System Events" to keystroke "w" using command down'
    #cmd + shift - v : yabai -m window --toggle float

    # Focus windows (vim-like)
    #        cmd - left : yabai -m window --focus west
    #        cmd - right : yabai -m window --focus east
    #        cmd - up : yabai -m window --focus north
    #        cmd - down : yabai -m window --focus south

    # Move windows to spaces (workspaces)
    #       cmd + shift - 1 : yabai -m window --space 1
    #       cmd + shift - 2 : yabai -m window --space 2
    #       cmd + shift - 3 : yabai -m window --space 3
    #       cmd + shift - 4 : yabai -m window --space 4
    #       cmd + shift - 5 : yabai -m window --space 5
    #       cmd + shift - 6 : yabai -m window --space 6
    #       cmd + shift - 7 : yabai -m window --space 7
    #       cmd + shift - 8 : yabai -m window --space 8
    #       cmd + shift - 9 : yabai -m window --space 9
    #       cmd + shift - 0 : yabai -m window --space 10

    # Switch to spaces (workspaces)
    #       cmd - 1 : yabai -m space --focus 1
    #       cmd - 2 : yabai -m space --focus 2
    #       cmd - 3 : yabai -m space --focus 3
    #       cmd - 4 : yabai -m space --focus 4
    #       cmd - 5 : yabai -m space --focus 5
    #       cmd - 6 : yabai -m space --focus 6
    #       cmd - 7 : yabai -m space --focus 7
    #       cmd - 8 : yabai -m space --focus 8
    #       cmd - 9 : yabai -m space --focus 9
    #       cmd - 0 : yabai -m space --focus 10

    # Screenshot (macOS native)
    #       cmd - z : screencapture -i ~/Pictures/Screenshots/$(date +%s).png
    #       cmd - u : screencapture ~/Pictures/Screenshots/$(date +%s).png

    # Launcher (using Raycast or Spotlight as Rofi alternative)
    #       cmd - r : open -a "Raycast" || osascript -e 'tell application "System Events" to keystroke space using command down'

    # Lock screen
    #       cmd - m : pmset displaysleepnow

    # Toggle layout (if using yabai)
    #       cmd - j : yabai -m space --layout $(yabai -m query --spaces --space | jq -r 'if .type == "bsp" then "float" else "bsp" end')
    #       cmd - p : yabai -m window --toggle split

    # Reload skhd config
    #        cmd + shift - r : skhd --reload
    #      '';
    #    };
  };
}
