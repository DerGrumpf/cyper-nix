{
  config,
  ...
}:
let
  domain = "mastodon.cyperpunk.de";
in
{
  sops.secrets = {
    "services/mastodon/secret_key_base" = {
      owner = "mastodon";
      group = "mastodon";
    };
    "services/mastodon/vapid_private_key" = {
      owner = "mastodon";
      group = "mastodon";
    };
    "services/mastodon/vapid_public_key" = {
      owner = "mastodon";
      group = "mastodon";
    };
    "services/mastodon/ar_encryption_deterministic_key" = {
      owner = "mastodon";
      group = "mastodon";
    };
    "services/mastodon/ar_encryption_key_derivation_salt" = {
      owner = "mastodon";
      group = "mastodon";
    };
    "services/mastodon/ar_encryption_primary_key" = {
      owner = "mastodon";
      group = "mastodon";
    };
    "services/mastodon/db_password" = {
      owner = "mastodon";
      group = "mastodon";
    };
    "kanidm/mastodon_secret" = {
      owner = "mastodon";
      group = "mastodon";
      mode = "0444";
    };
  };

  environment.persistence."/persist".directories = [
    {
      directory = "/var/lib/mastodon";
      user = "mastodon";
      group = "mastodon";
      mode = "0750";
    }
  ];

  services = {
    mastodon = {
      enable = true;
      localDomain = domain;
      configureNginx = true;

      streamingProcesses = 2;

      secretKeyBaseFile = config.sops.secrets."services/mastodon/secret_key_base".path;
      vapidPublicKeyFile = config.sops.secrets."services/mastodon/vapid_public_key".path;
      vapidPrivateKeyFile = config.sops.secrets."services/mastodon/vapid_private_key".path;

      activeRecordEncryptionDeterministicKeyFile =
        config.sops.secrets."services/mastodon/ar_encryption_deterministic_key".path;
      activeRecordEncryptionKeyDerivationSaltFile =
        config.sops.secrets."services/mastodon/ar_encryption_key_derivation_salt".path;
      activeRecordEncryptionPrimaryKeyFile =
        config.sops.secrets."services/mastodon/ar_encryption_primary_key".path;

      database = {
        createLocally = true;
        passwordFile = config.sops.secrets."services/mastodon/db_password".path;
      };

      redis.createLocally = true;

      smtp = {
        createLocally = false;
        fromAddress = "mastodon@cyperpunk.de";
        # TODO: set host/port/authenticate = true + user/passwordFile once
        # you pick a real mail provider - required for confirmation emails
      };

      extraConfig = {
        SINGLE_USER_MODE = "false";
        AUTHORIZED_FETCH = "true";
      };
    };
  };
}
