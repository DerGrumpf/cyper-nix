{ pkgs, ... }:
{

  services = {
    paperless = {
      enable = true;
      package = pkgs.paperless-ngx;
      address = "0.0.0.0";
      port = 28101;
      settings = {
        PAPERLESS_USE_X_FORWARDED_HOST = "true";
        PAPERLESS_USE_X_FORWARDED_PORT = "true";
        PAPERLESS_ALLOWED_HOSTS = "ngx.cyperpunk.de,100.109.179.25,localhost";
        PAPERLESS_CSRF_TRUSTED_ORIGINS = [
          "https://ngx.cyperpunk.de"
          "http://100.109.179.25:28101"
        ];
        PAPERLESS_OCR_LANGUAGE = "deu+eng";
        PAPERLESS_CONSUMPTION_DIR = "/var/lib/paperless/consume";
        PAPERLESS_URL = "https://ngx.cyperpunk.de";
      };

      exporter = {
        enable = true;
      };
    };
  };

  users.users.paperless.extraGroups = [ "users" ];

  systemd.tmpfiles.rules = [
    "d /storage/internal/paperless 0775 root users -"
    "z /storage/internal/paperless 0775 root users -"
  ];

  networking.firewall.allowedTCPPorts = [
    28101
  ];
}
