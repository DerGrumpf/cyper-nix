{
  config,
  ...
}:
let
  domain = "mastodon.cyperpunk.de";
in
{
  sops = {
    secrets = {
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
      "services/mastodon/smtp_password" = {
        owner = "mastodon";
        group = "mastodon";
      };
      "kanidm/mastodon_secret" = {
        owner = "mastodon";
        group = "mastodon";
        mode = "0440";
      };
    };

    templates."mastodon-oidc-env" = {
      owner = "mastodon";
      group = "mastodon";
      content = ''
        OIDC_CLIENT_SECRET=${config.sops.placeholder."kanidm/mastodon_secret"}
      '';
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
        host = "smtp.gmail.com";
        port = 587;
        authenticate = true;
        user = "phil.keier@gmail.com";
        passwordFile = config.sops.secrets."services/mastodon/smtp_password".path;
        fromAddress = "phil.keier@gmail.com";
      };

      extraEnvFiles = [ config.sops.templates."mastodon-oidc-env".path ];

      extraConfig = {
        SINGLE_USER_MODE = "false";
        AUTHORIZED_FETCH = "true";
        OIDC_ENABLED = "true";
        OIDC_DISPLAY_NAME = "Kanidm";
        OIDC_ISSUER = "https://auth.cyperpunk.de/oauth2/openid/mastodon";
        OIDC_DISCOVERY = "true";
        OIDC_SCOPE = "openid,profile,email";
        OIDC_UID_FIELD = "email";
        OIDC_CLIENT_ID = "mastodon";
        OIDC_REDIRECT_URI = "https://${domain}/auth/auth/openid_connect/callback";
        OIDC_SECURITY_ASSUME_EMAIL_IS_VERIFIED = "true";
        #        ALLOW_UNSAFE_AUTH_PROVIDER_REATTACH = "true";
      };
    };
  };
}
