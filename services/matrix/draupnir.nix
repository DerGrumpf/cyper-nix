{ config, ... }:
{
  sops.secrets."matrix/draupnir_access_token" = { };

  environment.persistence."/persist".directories = [
    {
      directory = "/var/lib/private";
      user = "root";
      group = "root";
      mode = "0700";
    }
  ];

  services.draupnir = {
    enable = true;
    secrets.accessToken = config.sops.secrets."matrix/draupnir_access_token".path;
    settings = {
      homeserverUrl = "https://matrix.cyperpunk.de";
      managementRoom = "!eErCimyDjLSebHjpJA:cyperpunk.de";
    };
  };
}
