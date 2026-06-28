{

  environment.persistence."/persist".directories = [
    {
      directory = "/var/lib/mautrix-whatsapp";
      user = "mautrix-whatsapp";
      group = "mautrix-whatsapp";
      mode = "0750";
    }
  ];

  services = {
    postgresql = {
      ensureUsers = [
        {
          name = "mautrix-whatsapp";
          ensureDBOwnership = true;
        }
      ];
      ensureDatabases = [ "mautrix-whatsapp" ];
    };

    mautrix-whatsapp = {
      enable = true;
      settings = {
        homeserver = {
          address = "http://127.0.0.1:8008";
          domain = "cyperpunk.de";
        };
        database = {
          type = "postgres";
          uri = "postgres:///mautrix-whatsapp?host=/run/postgresql&sslmode=disable";
        };
        bridge.permissions = {
          "cyperpunk.de" = "user";
          "@dergrumpf:cyperpunk.de" = "admin";
        };
      };
    };
  };
}
