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
  imports = [ inputs.catppuccin.nixosModules.catppuccin ];

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
    "services/forgejo/runner_token" = {
      mode = "0444";
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
    {
      directory = "/var/lib/postgresql";
      user = "postgres";
      group = "postgres";
      mode = "0750";
    }
  ];

  systemd = {
    services = {
      forgejo-db-password = {
        description = "Set forgejo postgres user password";
        requires = [
          "postgresql.service"
          "postgresql-setup.service"
        ];
        after = [
          "postgresql.service"
          "postgresql-setup.service"
        ];
        before = [ "forgejo.service" ];
        wantedBy = [ "forgejo.service" ];
        serviceConfig = {
          Type = "oneshot";
          User = "postgres";
          RemainAfterExit = true;
        };
        script = ''
          pass=$(cat ${config.sops.secrets."services/forgejo/db_password".path})
          ${pkgs.postgresql_14}/bin/psql -c \
            "ALTER USER forgejo WITH PASSWORD '$pass';"
        '';
      };

      "gitea-runner-docker_runner".serviceConfig.SupplementaryGroups = [ "docker" ];
      "gitea-runner-cyper_nix".serviceConfig = {
        LoadCredential = "deploy_ssh_key:/home/phil/.ssh/ssh";
        ProtectSystem = "full";
        DynamicUser = lib.mkForce false;
      };
    };

    tmpfiles.rules = [
      "d /var/lib/forgejo 0750 forgejo forgejo -"
      "d /var/lib/forgejo/custom 0750 forgejo forgejo -"
      "d /var/lib/forgejo/custom/conf 0750 forgejo forgejo -"
    ];
  };

  services = {
    postgresql = {
      enable = true;
      package = pkgs.postgresql_14;
      ensureDatabases = [ "forgejo" ];
      ensureUsers = [
        {
          name = "forgejo";
          ensureDBOwnership = true;
        }
      ];
      authentication = lib.mkOverride 10 ''
        local all all trust
        host  all all 127.0.0.1/32 md5
        host  all all ::1/128      md5
      '';
    };

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

        metrics = {
          ENABLED = true;
          ENABLED_ISSUE_BY_LABEL = true;
          ENABLED_ISSUE_BY_REPOSITORY = true;
        };
      };
    };

    gitea-actions-runner = {
      package = pkgs.forgejo-runner;
      instances = {
        cyper_nix = {
          enable = true;
          url = "https://git.cyperpunk.de";
          tokenFile = config.sops.secrets."services/forgejo/runner_token".path;
          name = "cyper-controller";
          labels = [ "nix:host" ];

          hostPackages = with pkgs; [
            bash
            coreutils
            curl
            gawk
            gitMinimal
            gnused
            nodejs
            pnpm
            rsync
            wget
            nix
            openssh
            nixos-rebuild
          ];

          settings.runner.env_vars = {
            PATH = "/run/wrappers/bin:/nix/var/nix/profiles/default/bin:/run/current-system/sw/bin:/usr/bin:/bin";
          };
        };

        docker_runner = {
          enable = true;
          url = "https://git.cyperpunk.de";
          tokenFile = config.sops.secrets."services/forgejo/runner_token".path;
          name = "docker-runner";
          labels = [ "docker:host" ];
          hostPackages = with pkgs; [
            bash
            coreutils
            curl
            gitMinimal
            docker
            nodejs
          ];
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
