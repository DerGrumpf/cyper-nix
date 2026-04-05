{
  widgets = {
    "hyprland/workspaces" = {
      format = "{icon}";
      format-icons = {
        default = " ";
        active = " ";
      };
    };
    "custom/mako" = {
      tooltip = false;
      format = "{}";
      return-type = "json";
      exec = "sh ~/.config/waybar/mako.sh";
      on-click = "makoctl mode -t do-not-disturb";
      interval = 1;
    };
  };
}
