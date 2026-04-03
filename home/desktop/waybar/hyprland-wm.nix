{
  widgets = {
    "hyprland/workspaces" = {
      format = "{icon}";
      format-icons = {
        default = "";
        active = "";
      };
    };
    "custom/mako" = {
      tooltip = false;
      format = "{icon}";
      format-icons = {
        enabled = " ";
        disabled = " ";
      };
      return-type = "json";
      exec = "makoctl mode | grep -q do-not-disturb && echo '{\"text\":\"\",\"class\":\"disabled\"}' || echo '{\"text\":\"\",\"class\":\"enabled\"}'";
      on-click = "makoctl mode -t do-not-disturb";
      interval = 1;
    };
  };
}
