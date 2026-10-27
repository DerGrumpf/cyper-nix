{ pkgs, ... }:
let
  cinnyConfigured = pkgs.cinny-unwrapped.overrideAttrs (_: {
    postInstall = ''
      cp ${
        builtins.toFile "cinny-config.json" (
          builtins.toJSON {
            defaultHomeserver = 0;
            homeserverList = [ "cyperpunk.de" ];
            allowCustomHomeservers = false;
          }
        )
      } $out/config.json
    '';
  });
in
{
  environment.persistence."/persist".directories = [
    {
      directory = "/var/lib/containers";
      user = "root";
      group = "root";
      mode = "0700";
    }
  ];

  services.nginx.virtualHosts = {
    "cinny.cyperpunk.de" = {
      forceSSL = true;
      enableACME = true;
      root = "${cinnyConfigured}";
      locations."/" = {
        tryFiles = "$uri $uri/ /index.html";
      };
    };
  };
}
