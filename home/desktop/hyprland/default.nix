{ inputs, pkgs, ... }:
let
  super = "SUPER";
  terminal = "kitty";
  fileManager = "yazi";
  theme = "-theme $HOME/.config/rofi/custom.rasi";
  menu = "rofi -show drun ${theme}";
  filebrowser = "rofi -show filebrowser ${theme}";
  power =
    "rofi -show p -modi p:rofi-power-menu -theme $HOME/.config/rofi/power.rasi";
  apps = "rofi -show window ${theme}";
in {

  imports = [ ./hypridle.nix ./hyprlock.nix ./mako.nix ./portal.nix ];

  home.packages = with pkgs; [
    catppuccin-cursors.mochaDark
    grim
    slurp
    wl-clipboard
    pamixer
    brightnessctl
    playerctl
  ];

  systemd.user.targets.hyprland-session.Unit.Wants =
    [ "xdg-desktop-autostart.target" ];

  wayland.windowManager.hyprland = {
    package =
      inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
    enable = true;

    xwayland.enable = true;

    systemd = {
      enable = true;
      variables = [ "--all" ];
      enableXdgAutostart = false;
    };

    plugins =
      with inputs.hyprland-plugins.packages.${pkgs.stdenv.hostPlatform.system};
      [
        #hyprbars
        #      hyprexpo
      ];

    settings = {
      env = [
        "NIXOS_OZONE_WL,1"
        "MOZ_ENABLE_WAYLAND,1"
        "MOZ_WEBRENDER,1"
        "_JAVA_AWT_WM_NONREPARENTING,1"
        "QT_WAYLAND_DISABLE_WINDOWDECORATION,1"
        "QT_QPA_PLATFORM,wayland"
        "SDL_VIDEODRIVER,wayland"
        "GDK_BACKEND,wayland,x11"
        "XCURSOR_SIZE,24"
        "EDITOR,nvim"
        "GSK_RENDERER,gl"
        "HYPRCURSOR_THEME,catppuccin-mocha-dark"
        "HYPRCURSOR_SIZE,24"
        "XCURSOR_THEME,catppuccin-mocha-dark"
        "XCURSOR_SIZE,24"
      ];

      monitor =
        [ "DP-1, 1920x1080@60, 1920x0, 1" "HDMI-A-2, 1920x1080@60, 0x0, 1" ];

      input = {
        kb_layout = "de";
        kb_variant = "mac";
        kb_options = "apple:fn_lock";
        repeat_rate = 50;
        repeat_delay = 300;

        accel_profile = "flat";
        follow_mouse = 1;
        mouse_refocus = false;
        sensitivity = 0; # -1.0 to 1.0, 0 means no modification.

        numlock_by_default = 1;
        touchpad = {
          natural_scroll = true;
          tap-to-click = true;
        };

      };

      general = {
        # See https://wiki.hyprland.org/Configuring/Variables/ for more
        gaps_in = 2;
        gaps_out = 0;
        border_size = 4;

        "col.active_border" = "$green";
        "col.inactive_border" = "$red";

        layout = "dwindle";

        # Please see https://wiki.hyprland.org/Configuring/Tearing/ before you turn this on
        allow_tearing = false;
      };

      decoration = {
        rounding = 1;

        shadow = {
          enabled = false;
          range = 16;
          render_power = 4;
          ignore_window = true;
          color = "$green";
          color_inactive = "$red";
        };

        blur = {
          enabled = false;
          size = 1;
          passes = 3;
          new_optimizations = 1;
          noise = 4.0e-2;
        };
      };

      animations = {
        enabled = "yes";
        bezier = "myBezier, 0.05, 0.9, 0.1, 1.05";
        animation = [
          "windows, 1, 7, myBezier"
          "windowsOut, 1, 7, default, popin 80%"
          "border, 1, 10, default"
          "borderangle, 1, 8, default"
          "fade, 1, 7, default"
          "workspaces, 1, 6, default"
        ];
      };

      #    layerrule = [
      # "ignorezero,notifications"
      # "ignorezero,rofi"
      #   ];

      dwindle = {
        pseudotile = "yes";
        preserve_split = "yes";
      };

      #      gestures = {
      # See https://wiki.hyprland.org/Configuring/Variables/ for more
      #        workspace_swipe = true;
      #        workspace_swipe_fingers = 3;
      #        workspace_swipe_distance = 300;
      #        workspace_swipe_invert = false;
      #        workspace_swipe_cancel_ratio = 0.5;
      #      };

      misc = {
        force_default_wallpaper = 0;
        disable_hyprland_logo = true;
        disable_splash_rendering = true;
        mouse_move_enables_dpms = true;
        key_press_enables_dpms = true;
        vfr = true;
        vrr = 0;
      };

      device = {
        name = "usb-optical-mouse-";
        sensitivity = 0;
      };
      #deprecated
      #      windowrulev2 = [
      #       "suppressevent maximize, class:.*"
      #      "float, class:^(com.obsproject.Studio)$"
      #      "size 1280 800, class:^(com.obsproject.Studio)$"
      #      "float, class:^(xdg-desktop-portal-gtk)$"
      #     "center, class:^(xdg-desktop-portal-gtk)$"
      #  ];

      #      windowrule = [
      #  "opacity 0.0 override, class:^(xwaylandvideobridge)$"
      #  "noanim, class:^(xwaylandvideobridge)$"
      #  "noinitialfocus, class:^(xwaylandvideobridge)$"
      #  "maxsize 1 1, class:^(xwaylandvideobridge)$"
      #  "noblur, class:^(xwaylandvideobridge)$"
      #  "nofocus, class:^(xwaylandvideobridge)$"
      #  "noblur, class:^(org\\.gnome\\.|io\\.github\\.|org\\.gtk\\.)"
      #     ];

      exec-once = [ "awww-daemon & disown" "waybar &" ];

      # Keybindings
      bind = [

        # Application Bindings
        "${super}, Q, exec, ${terminal}"
        "${super}, E, exec, ${fileManager}"
        "${super}, O, exec, obsidian"
        "${super}, I, exec, floorp"
        "${super}, G, exec, thunderbird"
        ", XF86Mail, exec, thunderbird"
        "${super}, N, exec, nautilus"
        ", XF86Search, exec, nautilus"

        # Lock Screen
        "${super}, M, exit, "

        # Rofi bindings
        "${super}, F, exec, ${filebrowser}"
        "${super}, A, exec, ${apps}"
        ", Menu, exec, ${apps}"
        "${super}, R, exec, ${menu}"
        ", XF86LaunchA, exec, ${menu}"
        "${super}, S, exec, ${power}"
        ", XF86LaunchB, exec, ${power}"

        # Move focus with mainMod + arrow keys
        "${super}, left, movefocus, l"
        "${super}, right, movefocus, r"
        "${super}, up, movefocus, u"
        "${super}, down, movefocus, d"

        # Window Modifiers
        "${super}, P, pseudo, " # dwindle
        #        "${super}, J, togglesplit, " # dwindle doenst exist
        "${super}, V, togglefloating, " # dwindle
        "${super}, C, killactive, "

        # Switch workspaces with mainMod + [0-9]
        "${super}, 1, workspace, 1"
        "${super}, 2, workspace, 2"
        "${super}, 3, workspace, 3"
        "${super}, 4, workspace, 4"
        "${super}, 5, workspace, 5"
        "${super}, 6, workspace, 6"
        "${super}, 7, workspace, 7"
        "${super}, 8, workspace, 8"
        "${super}, 9, workspace, 9"
        "${super}, 0, workspace, 10"

        # Move active window to a workspace with mainMod + SHIFT + [0-9]
        "${super} SHIFT, 1, movetoworkspace, 1"
        "${super} SHIFT, 2, movetoworkspace, 2"
        "${super} SHIFT, 3, movetoworkspace, 3"
        "${super} SHIFT, 4, movetoworkspace, 4"
        "${super} SHIFT, 5, movetoworkspace, 5"
        "${super} SHIFT, 6, movetoworkspace, 6"
        "${super} SHIFT, 7, movetoworkspace, 7"
        "${super} SHIFT, 8, movetoworkspace, 8"
        "${super} SHIFT, 9, movetoworkspace, 9"
        "${super} SHIFT, 0, movetoworkspace, 10"

        # Example special workspace (scratchpad)
        #"${super}, S, togglespecialworkspace, magic"
        "${super} SHIFT, S, movetoworkspace, special:magic"

        # Scroll through existing workspaces with mainMod + scroll
        "${super}, mouse_down, workspace, e+1"
        "${super}, mouse_up, workspace, e-1"

        # Screenshot
        ''
          ${super}, Z, exec, grim -g "$(slurp)" $HOME/Pictures/Screenshots/$(date +'%s_grim.png')''
        "${super}, U, exec, grim $HOME/Pictures/Screenshots/$(date +'%s_grim.png')"
      ];

      bindl = [
        #", XF86AudioMute, exec, amixer set Master toggle
        ", XF86AudioMute, exec, pamixer -t"
        ", XF86AudioPlay, exec, playerctl play-pause" # the stupid key is called play , but it toggles
        ", XF86AudioNext, exec, playerctl next"
        ", XF86AudioPrev, exec, playerctl previous"
      ];

      bindle = [
        # Multi Media Control
        ", XF86AudioRaiseVolume, exec, pamixer -i 5"
        ", XF86AudioLowerVolume, exec, pamixer -d 5"
        ", XF86MonBrightnessUp, exec, brightnessctl set +5%"
        ", XF86MonBrightnessDown, exec, brightnessctl set 5%-"
      ];

      bindm = [
        "${super}, mouse:272, movewindow"
        "${super}, mouse:273, resizewindow"
      ];
    };
  };
}
