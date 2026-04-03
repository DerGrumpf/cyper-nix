{
  compositor ? "hyprland",
}:
let
  common = import ./common.nix;
  wm = if compositor == "hyprland" then import ./hyprland-wm.nix else import ./niri-wm.nix;
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
        "hyprland/workspaces"
        "niri/workspaces"
        "custom/mako"
        "custom/swaync"
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
        "hyprland/workspaces"
        "niri/workspaces"
      ];
      modules-right = [ "custom/weather" ];
    }
    // common.widgets
    // wm.widgets;
  };

}
