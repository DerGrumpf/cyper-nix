{
  config,
  pkgs,
  lib,
  ...
}:

let
  address = config.systemd.network.networks."10-ethernet".networkConfig.Address;
  ip = builtins.elemAt (lib.splitString "/" address) 0;
  port = 15005;

  catppuccinFlavor = "mocha";
  logo = if catppuccinFlavor == "latte" then "assets/light_circle.png" else "assets/dark_circle.png";

  mainConfig = pkgs.writeText "config.yml" ''
    title: "Dashboard"
    subtitle: ""
    header: true
    footer: false
    logo: "${logo}"
    stylesheet:
      - "assets/catppuccin-${catppuccinFlavor}.css"
    defaults:
      colorTheme: dark
    services:
      - name: "Services"
        items:
          - name: "Vaultwarden"
            url: "https://${ip}:8222"
          - name: "SearXNG"
            url: "http://${ip}:11080"
  '';

  mainRoot = pkgs.runCommand "homer-main" { } ''
    cp -r ${pkgs.homer}/. $out
    chmod -R u+w $out
    cp ${mainConfig} $out/config.yml
    mkdir -p $out/assets/icons
    cp ${./assets/flavours/catppuccin-${catppuccinFlavor}.css} $out/assets/catppuccin-${catppuccinFlavor}.css
    cp ${./assets/logos/dark_circle.png} $out/assets/dark_circle.png
    cp ${./assets/logos/light_circle.png} $out/assets/light_circle.png
  '';
in
{
  services.nginx.virtualHosts."homer-main" = {
    listen = [
      {
        inherit port;
        addr = "0.0.0.0";
      }
    ];
    root = "${mainRoot}";
    locations."/" = {
      index = "index.html";
      tryFiles = "$uri $uri/ /index.html";
    };
  };

  networking.firewall.allowedTCPPorts = [ port ];
}
