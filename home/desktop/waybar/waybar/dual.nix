{
  compositor ? "hyprland",
}:
let
  common = import ./common.nix;
  wm = if compositor == "hyprland" then import ./hyprland-wm.nix else import ./niri-wm.nix;
  workspaceModule = if compositor == "hyprland" then "hyprland/workspaces" else "niri/workspaces";
  notificationModule = if compositor == "hyprland" then "custom/mako" else "custom/swaync";
in
{
  enable = true;
  settings = {
    mainBar = {
      layer = "top";
      position = "top";
      height = 30;
      output = [ "DP-1" ];
      modules-left = [
        "custom/nixicon"
        "clock"
      ];
      modules-center = [
        workspaceModule
        notificationModule
      ];
      modules-right = [
        "group/hardware"
      ];
    }
    // common.widgets
    // wm.widgets;

    secondBar = {
      layer = "top";
      position = "top";
      height = 30;
      output = [ "HDMI-A-2" ];
      modules-left = [
        "group/media"
        "custom/wallpaper"
      ];
      modules-center = [
        workspaceModule
      ];
      modules-right = [ "custom/weather" ];
    }
    // common.widgets
    // wm.widgets;
  };

}
