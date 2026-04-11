{
  config,
  pkgs,
  lib,
  ...
}:

let
  address = config.systemd.network.networks."10-ethernet".networkConfig.Address;
  ip = builtins.elemAt (lib.splitString "/" address) 0;
  port = 15006;

  calvinConfig = pkgs.writeText "config.yml" ''
    title: "Calvin's Dashboard"
    subtitle: ""
    header: true
    footer: false
    defaults:
      colorTheme: dark
    services:
      - name: "Services"
        items: []
  '';

  calvinRoot = pkgs.runCommand "homer-calvin" { } ''
    cp -r ${pkgs.homer}/. $out
    chmod -R u+w $out
    cp ${calvinConfig} $out/config.yml
  '';
in
{
  services.nginx.virtualHosts."homer-calvin" = {
    listen = [
      {
        addr = "0.0.0.0";
        port = port;
      }
    ];
    root = "${calvinRoot}";
    locations."/" = {
      index = "index.html";
      tryFiles = "$uri $uri/ /index.html";
    };
  };

  networking.firewall.allowedTCPPorts = [ port ];
}
