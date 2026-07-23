{ pkgs, primaryUser, ... }:
let
  mochaTheme = builtins.concatStringsSep ";" [
    "border=blue"
    "text=white"
    "prompt=magenta"
    "time=green"
    "action=yellow"
    "button=yellow"
    "container=black"
    "input=white"
    "greet=magenta"
    "title=cyan"
  ];

  tuigreetArgs = builtins.concatStringsSep " " [
    "--time"
    "--remember"
    "--remember-user-session"
    "--asterisks"
    "--asterisks-char '#'"
    "--greeting 'Hey there!'"
    "--theme '${mochaTheme}'"
    "--cmd start-hyprland"
  ];
in
{
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.tuigreet}/bin/tuigreet ${tuigreetArgs}";
        user = "greeter";
      };
      initial_session = {
        command = "start-hyprland";
        user = primaryUser;
      };
    };
  };
}
