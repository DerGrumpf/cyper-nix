{
  pkgs,
  lib,
  config,
  primaryUser,
  ...
}:

let

  giteaTheme = pkgs.fetchzip {
    url = "https://github.com/catppuccin/gitea/releases/download/v1.0.1/catppuccin-gitea.tar.gz";
    sha256 = "sha256-et5luA3SI7iOcEIQ3CVIu0+eiLs8C/8mOitYlWQa/uI=";
    stripRoot = false;
  };

  domain = "git.cyperpunk.de";
  httpPort = 9000;
  sshPort = 12222;
in
{
  sops.secrets = {
    "gitea/dbPassword" = {
      owner = "gitea";
      group = "gitea";
      mode = "0444";
    };
    "gitea/internalToken" = {
      owner = "gitea";
      group = "gitea";
    };
    "gitea/lfsJwtSecret" = {
      owner = "gitea";
      group = "gitea";
    };
    "gitea/mailerPassword" = {
      owner = "gitea";
      group = "gitea";
    };
    "gitea/runnerToken" = {
      mode = "0444";
    };
    "kanidm_gitea_secret" = {
      owner = "gitea";
      group = "gitea";
      mode = "0444";
    };
  };

  systemd.services = {
    gitea-db-password = {
      description = "Set gitea postgres user password";
      requires = [ "postgresql.service" ];
      after = [ "postgresql.service" ];
      before = [ "gitea.service" ];
      wantedBy = [ "gitea.service" ];
      serviceConfig = {
        Type = "oneshot";
        User = "postgres";
        RemainAfterExit = true;
      };
      script = ''
        pass=$(cat ${config.sops.secrets."gitea/dbPassword".path})
        ${pkgs.postgresql_14}/bin/psql -c \
          "ALTER USER gitea WITH PASSWORD '$pass';"
      '';
    };

    gitea.preStart = lib.mkAfter ''
      themeDir="${config.services.gitea.stateDir}/custom/public/assets/css"
      mkdir -p "$themeDir"
      for f in ${giteaTheme}/*.css; do
        name=$(basename "$f")
        ln -sf "$f" "$themeDir/$name"
      done
    '';
  };

  services = {
    postgresql = {
      enable = true;
      package = pkgs.postgresql_14;
      ensureDatabases = [ "gitea" ];
      ensureUsers = [
        {
          name = "gitea";
          ensureDBOwnership = true;
        }
      ];
      authentication = lib.mkOverride 10 ''
        local all all trust
        host  all all 127.0.0.1/32 md5
        host  all all ::1/128      md5
      '';
    };

    gitea = {
      enable = true;
      package = pkgs.gitea;
      user = "gitea";
      group = "gitea";

      lfs = {
        enable = true;
        contentDir = "/storage/fast/lfs";
      };

      database = {
        type = "postgres";
        host = "127.0.0.1";
        port = 5432;
        name = "gitea";
        user = "gitea";
        passwordFile = config.sops.secrets."gitea/dbPassword".path;
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

        ui = {
          DEFAULT_THEME = "catppuccin-mocha-green";
          THEMES = lib.concatStringsSep "," [
            # built-in
            "gitea"
            "arc-green"
            # latte
            "catppuccin-latte-blue"
            "catppuccin-latte-flamingo"
            "catppuccin-latte-green"
            "catppuccin-latte-lavender"
            "catppuccin-latte-maroon"
            "catppuccin-latte-mauve"
            "catppuccin-latte-peach"
            "catppuccin-latte-pink"
            "catppuccin-latte-red"
            "catppuccin-latte-rosewater"
            "catppuccin-latte-sapphire"
            "catppuccin-latte-sky"
            "catppuccin-latte-teal"
            "catppuccin-latte-yellow"
            # frappe
            "catppuccin-frappe-blue"
            "catppuccin-frappe-flamingo"
            "catppuccin-frappe-green"
            "catppuccin-frappe-lavender"
            "catppuccin-frappe-maroon"
            "catppuccin-frappe-mauve"
            "catppuccin-frappe-peach"
            "catppuccin-frappe-pink"
            "catppuccin-frappe-red"
            "catppuccin-frappe-rosewater"
            "catppuccin-frappe-sapphire"
            "catppuccin-frappe-sky"
            "catppuccin-frappe-teal"
            "catppuccin-frappe-yellow"
            # macchiato
            "catppuccin-macchiato-blue"
            "catppuccin-macchiato-flamingo"
            "catppuccin-macchiato-green"
            "catppuccin-macchiato-lavender"
            "catppuccin-macchiato-maroon"
            "catppuccin-macchiato-mauve"
            "catppuccin-macchiato-peach"
            "catppuccin-macchiato-pink"
            "catppuccin-macchiato-red"
            "catppuccin-macchiato-rosewater"
            "catppuccin-macchiato-sapphire"
            "catppuccin-macchiato-sky"
            "catppuccin-macchiato-teal"
            "catppuccin-macchiato-yellow"
            # mocha
            "catppuccin-mocha-blue"
            "catppuccin-mocha-flamingo"
            "catppuccin-mocha-green"
            "catppuccin-mocha-lavender"
            "catppuccin-mocha-maroon"
            "catppuccin-mocha-mauve"
            "catppuccin-mocha-peach"
            "catppuccin-mocha-pink"
            "catppuccin-mocha-red"
            "catppuccin-mocha-rosewater"
            "catppuccin-mocha-sapphire"
            "catppuccin-mocha-sky"
            "catppuccin-mocha-teal"
            "catppuccin-mocha-yellow"
          ];
        };
      };
    };

    gitea-actions-runner.instances."cyper_nix" = {
      enable = true;
      url = "https://git.cyperpunk.de";
      tokenFile = config.sops.secrets."gitea/runnerToken".path;
      name = "cyper-controller";
      labels = [ "nix:host" ];
      hostPackages = with pkgs; [
        nodejs
        git
        nix
        bash
      ];
      settings = {
        runner.env_vars = {
          PATH = "/run/wrappers/bin:/nix/var/nix/profiles/default/bin:/run/current-system/sw/bin:/usr/bin:/bin";
        };
      };
    };
  };

  system.activationScripts.gitea-runner-age-key = {
    deps = [
      "users"
      "groups"
    ];
    text = ''
      mkdir -p /var/lib/gitea-runner/.config/sops/age
      cp /home/phil/.config/nix/secrets/keys.txt /var/lib/gitea-runner/.config/sops/age/keys.txt
      chmod 600 /var/lib/gitea-runner/.config/sops/age/keys.txt
      chown -R gitea-runner:gitea-runner /var/lib/gitea-runner/.config
    '';
  };

  users = {
    users = {
      gitea = {
        isSystemUser = true;
        group = "gitea";
        home = "/var/lib/gitea";
        createHome = true;
      };
      gitea-runner = {
        isSystemUser = true;
        group = "gitea-runner";
        home = "/var/lib/gitea-runner";
        createHome = true;
      };
      postgres.extraGroups = [ "gitea" ];
    };
    groups = {
      gitea = { };
      gitea-runner = { };
    };
  };

  networking.firewall.allowedTCPPorts = [
    httpPort
    sshPort
  ];
}
