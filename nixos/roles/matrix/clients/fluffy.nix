{
  # FluffyChat virtual host - disabled: no DNS record for fluffy.cyperpunk.de
  services.nginx.virtualHosts."fluffy.cyperpunk.de" = {
    forceSSL = true;
    enableACME = true;
    locations."/" = {
      proxyPass = "http://127.0.0.1:8082";
      proxyWebsockets = true;
    };
  };

  # FluffyChat container - disabled: no DNS record for fluffy.cyperpunk.de
  virtualisation.oci-containers.containers.fluffychat = {
    image = "ghcr.io/krille-chan/fluffychat:latest";
    ports = [ "127.0.0.1:8082:80" ];
    volumes = [
      "${
        builtins.toFile "fluffychat-config.json" (
          builtins.toJSON {
            default_homeserver = "matrix.cyperpunk.de";
            preset_homeserver = "matrix.cyperpunk.de";
          }
        )
      }:/app/config.json:ro"
    ];
  };
}
