{
  pkgs,
  lib,
  config,
  inputs,
  primaryUser,
  ...
}:

let
  domain = "git.cyperpunk.de";
  httpPort = 9000;
  sshPort = 12222;
in
{
  imports = [
    inputs.catppuccin.nixosModules.catppuccin
    ./woodpecker.nix
  ];

  catppuccin = {
    enable = true;
    autoEnable = false;
    accent = "sky";
    flavor = "mocha";
    forgejo.enable = true;
  };

  sops.secrets = {
    "services/forgejo/db_password" = {
      owner = "forgejo";
      group = "forgejo";
      mode = "0444";
    };
    "services/forgejo/internal_token" = {
      owner = "forgejo";
      group = "forgejo";
    };
    "services/forgejo/lfs_jwt_secret" = {
      owner = "forgejo";
      group = "forgejo";
    };
    "kanidm/forgejo_secret" = {
      owner = "forgejo";
      group = "forgejo";
      mode = "0444";
    };
  };

  environment.persistence."/persist".directories = [
    {
      directory = "/var/lib/forgejo";
      user = "forgejo";
      group = "forgejo";
      mode = "0750";
    }
  ];

  systemd = {
    tmpfiles.rules = [
      "d /var/lib/forgejo 0750 forgejo forgejo -"
      "d /var/lib/forgejo/custom 0750 forgejo forgejo -"
      "d /var/lib/forgejo/custom/conf 0750 forgejo forgejo -"
    ];
  };

  services = {
    forgejo = {
      enable = true;
      package = pkgs.forgejo;
      user = "forgejo";
      group = "forgejo";

      lfs = {
        enable = true;
        contentDir = "/storage/fast/lfs";
      };

      database = {
        type = "postgres";
        host = "127.0.0.1";
        port = 5432;
        name = "forgejo";
        user = "forgejo";
        passwordFile = config.sops.secrets."services/forgejo/db_password".path;
      };

      settings = {
        service = {
          ENABLE_INTERNAL_SIGNIN = false;
          DISABLE_REGISTRATION = false;
          ALLOW_ONLY_EXTERNAL_REGISTRATION = true;
          SHOW_REGISTRATION_BUTTON = false;
        };

        server = {
          DOMAIN = domain;
          HTTP_ADDR = "0.0.0.0";
          HTTP_PORT = httpPort;
          SSH_PORT = sshPort;
          SSH_LISTEN_PORT = sshPort;
          ROOT_URL = "https://${domain}/";
          DISABLE_SSH = false;
          START_SSH_SERVER = true;
          LFS_START_SERVER = true;
        };

        oauth2_client = {
          ENABLE_AUTO_REGISTRATION = true;
          USERNAME = "preferred_username";
          ACCOUNT_LINKING = "auto";
          UPDATE_AVATAR = true;
        };

        metrics = {
          ENABLED = true;
          ENABLED_ISSUE_BY_LABEL = true;
          ENABLED_ISSUE_BY_REPOSITORY = true;
        };
      };
    };

    kanidm.provision = {
      groups.forgejo_users = {
        members = [ primaryUser ];
      };

      systems.oauth2.forgejo = {
        displayName = "Forgejo";
        originUrl = "https://git.cyperpunk.de/user/oauth2/kanidm/callback";
        originLanding = "https://git.cyperpunk.de/";
        basicSecretFile = config.sops.secrets."kanidm/forgejo_secret".path;
        preferShortUsername = true;
        scopeMaps.forgejo_users = [
          "openid"
          "profile"
          "email"
        ];
      };
    };
  };

  users = {
    users = {
      forgejo = {
        isSystemUser = true;
        group = "forgejo";
        home = "/var/lib/forgejo";
        createHome = true;
      };

      postgres.extraGroups = [ "forgejo" ];
    };
    groups.forgejo = { };
  };

  networking.firewall.allowedTCPPorts = [
    httpPort
    sshPort
  ];
}
