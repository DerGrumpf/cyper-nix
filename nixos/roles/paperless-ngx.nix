{ pkgs, ... }:

{
  services.paperless = {
    enable = true;
    package = pkgs.paperless-ngx;
    address = "0.0.0.0";
    port = 28101;

    settings = {

      # Da der Proxy auf einem anderen Server (via Tailscale) liegt:
      # Erlaubt Paperless, die 'X-Forwarded-*' Header zu akzeptieren
      PAPERLESS_USE_X_FORWARDED_HOST = "true";
      PAPERLESS_USE_X_FORWARDED_PORT = "true";

      # Erlaubt den Zugriff über die Domain UND die Tailscale-IP
      # Der Stern '*' ist die einfachste Lösung für private Server
      PAPERLESS_ALLOWED_HOSTS = "ngx.cyperpunk.de,100.109.179.25,localhost";

      # Füge die IP auch zu den vertrauenswürdigen Ursprüngen hinzu (für CSRF)
      PAPERLESS_CSRF_TRUSTED_ORIGINS = [
        "https://ngx.cyperpunk.de"
        "http://100.109.179.25:28101"
      ];

      # Restliche Einstellungen bleiben gleich
      PAPERLESS_OCR_LANGUAGE = "deu+eng";
      PAPERLESS_CONSUMPTION_DIR = "/var/lib/paperless/consume"; # Falls du den Bind-Mount nutzt
      PAPERLESS_URL = "https://ngx.cyperpunk.de";
    };
  };

  # Gruppe und Berechtigungen wie besprochen
  users.users.paperless.extraGroups = [ "users" ];

  systemd.tmpfiles.rules = [
    "d /storage/internal/paperless 0775 root users -"
    "z /storage/internal/paperless 0775 root users -"
  ];

  # Öffne den Port für Tailscale (oder das lokale Netz)
  networking.firewall.allowedTCPPorts = [ 28101 ];
}
