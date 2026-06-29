{ config, ... }:
{

  sops.secrets = {
    paperless_admin = {
      owner = "paperless";
    };
    paperless_oidc_secret = {
      owner = "paperless";
    };
  };

  services.paperless = {
    enable = true;
    address = "0.0.0.0";
    port = 28101;
    domain = "ngx.cyperpunk.de";
    consumptionDir = "/storage/fast/paperless/consume";
    dataDir = "/storage/fast/paperless";
    configureTika = true;
    passwordFile = config.sops.secrets.paperless_admin.path;
    settings = {
      PAPERLESS_USE_X_FORWARDED_HOST = true;
      PAPERLESS_USE_X_FORWARDED_PORT = true;
      PAPERLESS_ALLOWED_HOSTS = "ngx.cyperpunk.de,10.10.0.2,localhost";
      PAPERLESS_CSRF_TRUSTED_ORIGINS = [
        "https://ngx.cyperpunk.de"
        "http://10.10.0.2:28101"
      ];
      PAPERLESS_OCR_LANGUAGE = "deu+eng";
      PAPERLESS_CONSUMER_POLLING = 60;
      PAPERLESS_APPS = "allauth.socialaccount.providers.openid_connect";
    };

    exporter = {
      enable = true;
      directory = "/storage/backup/paperless";
    };
  };

  users.users.paperless.extraGroups = [ "users" ];

  systemd = {
    tmpfiles.rules = [
      "d /storage/fast/paperless 0775 paperless paperless -"
      "d /storage/fast/paperless/media 0775 paperless paperless -"
      "d /storage/fast/paperless/consume 0775 paperless paperless -"
      "d /storage/backup/paperless 0775 root users -"
    ];

    services = {
      paperless-scheduler = {
        after = [ "systemd-tmpfiles-setup.service" ];
        requires = [ "systemd-tmpfiles-setup.service" ];
      };
      paperless-web = {
        serviceConfig.EnvironmentFiles = [ config.sops.secrets.paperless_oidc_secret.path ];
      };
    };
  };
  networking.firewall.allowedTCPPorts = [ 28101 ];
}
