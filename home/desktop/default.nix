{ pkgs, ... }:
{
  imports = [
    ./hyprland
    ./rofi
    ./waybar
    ./gtk.nix
    ./qt.nix
  ];

  _module.args.compositor = "hyprland";

  home.packages = with pkgs; [
    waypaper
    awww
    onlyoffice-desktopeditors
  ];
  home.file.".config/waypaper/config.ini".source = ./waypaper.ini;

  programs = {
    mangohud = {
      enable = true;
      settings = {
        position = "top-right";
        offset_x = 20;
        offset_y = 20;
        fps = true;
        cpu_stats = true;
        gpu_stats = true;
        cpu_temp = true;
        gpu_temp = true;
        ram = true;
        vram = true;
        background_alpha = 0.5;
      };
    };
    mpv.enable = true;
    onlyoffice = {
      enable = true;
      settings = {
        UITheme = "theme-night";
        appdata = "@ByteArray(eyJ1c2VybmFtZSI6InBoaWwiLCJkb2NvcGVubW9kZSI6ImVkaXQiLCJyZXN0YXJ0Ijp0cnVlLCJsYW5naWQiOiJlbi1VUyIsInVpc2NhbGluZyI6IjAiLCJ1aXRoZW1lIjoidGhlbWUtbmlnaHQiLCJlZGl0b3J3aW5kb3dtb2RlIjpmYWxzZSwic3BlbGxjaGVja2RldGVjdCI6ImF1dG8iLCJ1c2VncHUiOnRydWV9)";
        editorWindowMode = false;
        titlebar = "custom";
      };
    };
  };
}
