{
  widgets = {
    "group/media" = {
      orientation = "horizontal";

      modules = [
        "mpris"
        "custom/cava"
        "wireplumber"
      ];
    };

    mpris = {
      format = "{player_icon}";
      format-paused = "{status_icon}";
      max-length = 100;
      player-icons = {
        default = "||";
        mpv = "||";
      };
      status-icons = {
        paused = "▶";
      };
    };

    "custom/cava" = {
      exec = "sh ~/.config/waybar/cava.sh";
      format = "{} ♪";
      on-click = "hyprctl dispatch focuswindow class:spotify";
    };

    wireplumber = {
      format = "{volume}%";
      format-muted = "";
      max-volume = 110;
      scroll-step = 0.2;
    };

    "group/hardware" = {
      orientation = "horizontal";
      modules = [
        "cpu"
        "network"
        "memory"
        "disk"
        "temperature"
      ];
    };

    network = {
      # Wifi
      tooltip = true;
      format-wifi = "{icon} ";
      format-icons = [
        "󰤟"
        "󰤢"
        "󰤥"
      ];
      rotate = 0;

      # Ethernet
      format-ethernet = "⇵{bandwidthTotalBits}";
      tooltip-format = "Network: <big><b>{essid}</b></big>\nSignal strength: <b>{signaldBm}dBm ({signalStrength}%)</b>\nFrequency: <b>{frequency}MHz</b>\nInterface: <b>{ifname}</b>\nIP: <b>{ipaddr}/{cidr}</b>\nGateway: <b>{gwaddr}</b>\nNetmask: <b>{netmask}</b>\nCurrent󰈀 : <b>{bandwidthTotalBits}</b>\nUp 󰶣: <b>{bandwidthUpBits}</b>\nDown 󰶡: <b>{bandwidthDownBits}</b>";
      format-linked = "󰈀 {ifname} (No IP)";
      format-disconnected = " ";
      tooltip-format-disconnected = "Disconnected";
      interval = 2;
    };

    memory = {
      interval = 1;
      #rotate = 270;
      format = "{icon} {percentage}%";
      format-icons = [
        "󰝦"
        "󰪞"
        "󰪟"
        "󰪠"
        "󰪡"
        "󰪢"
        "󰪣"
        "󰪤"
        "󰪥"
      ];
      max-length = 10;
    };

    cpu = {
      interval = 1;
      format = "{icon} {usage}%";
      #rotate = 270;
      format-icons = [
        "󰝦"
        "󰪞"
        "󰪟"
        "󰪠"
        "󰪡"
        "󰪢"
        "󰪣"
        "󰪤"
        "󰪥"
      ];
    };

    temperature = {
      format = " {temperatureC}°C";
      thermal-zone = 0;
      hwmon-path = "/sys/class/thermal/thermal_zone1/temp";
      critical-threshold = 80;
    };

    disk = {
      format = " {percentage_free}%";
      tooltip = true;
      tooltip-format = "{free} / {total} ({percentage_free})";
    };

    clock = {
      format = "{:%a %b %d, %I:%M %p}";
      rotate = 0;
      on-click = " ";
      tooltip-format = "<tt>{calendar}</tt>";
      calendar = {
        mode = "month";
        mode-mon-col = 3;
        on-scroll = 1;
        on-click-right = "mode";
        format = {
          months = "<span color='#cba6f7'><b>{}</b></span>";
          weekdays = "<span color='#74c7ec'><b>{}</b></span>";
          today = "<span color='#f38ba8'><b>{}</b></span>";
        };
      };
      actions = {
        on-click-right = "mode";
        on-click-forward = "tz_up";
        on-click-backward = "tz_down";
        on-scroll-up = "shift_up";
        on-scroll-down = "shift_down";
      };
    };

    "custom/nixicon" = {
      format = " ";
      on-click = "rofi -show drun -theme $HOME/.config/rofi/custom.rasi";
      tooltip = false;
    };

    "custom/weather" = {
      format = "{}";
      return-type = "json";
      exec = ''
        curl -sf --max-time 10 "https://api.openweathermap.org/data/2.5/weather?lat=52.281311&lon=10.527029&appid=$(cat ~/.config/sops-nix/secrets/system/openweather)&units=metric&lang=en" | jq -c '{text: "\(.name) \(.main.temp)C°"}'
      '';
      interval = 120;
      on-click = ''
        data=$(curl -sf --max-time 10 "https://api.openweathermap.org/data/2.5/weather?lat=52.281311&lon=10.527029&appid=$(cat ~/.config/sops-nix/secrets/system/openweather)&units=metric&lang=en")
        city=$(echo "$data" | jq -r '.name')
        temp=$(echo "$data" | jq -r '.main.temp')
        feels=$(echo "$data" | jq -r '.main.feels_like')
        humidity=$(echo "$data" | jq -r '.main.humidity')
        wind=$(echo "$data" | jq -r '.wind.speed')
        clouds=$(echo "$data" | jq -r '.clouds.all')
        sunrise=$(echo "$data" | jq -r '.sys.sunrise | strftime("%H:%M")')
        sunset=$(echo "$data" | jq -r '.sys.sunset | strftime("%H:%M")')
        notify-send "$city" "Temperature: $temp °C\nFeels Like: $feels °C\nHumidity: $humidity%\nWind: $wind m/s\nClouds: $clouds%\nSunrise at: $sunrise\nSunset at: $sunset" -u normal --icon="$HOME/Pictures/Avatar/miku_window_no_bg.png"
      '';
    };

    "custom/wallpaper" = {
      format = "【{} 】";
      exec = "basename $(awww query | grep -oP 'image: \\K.*')";
      interval = 5;
      on-click = "waypaper";
      tooltip = true;
      tooltip-format = "{}";
      max-length = 30;
    };
  };

}
