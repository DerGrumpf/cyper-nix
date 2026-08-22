{ config, pkgs, ... }:
{
  sops = {
    secrets = {
      "services/woodpecker/agent_secret" = { };
      "services/woodpecker/forgejo_secret" = { };
    };

    templates = {
      "woodpecker-agent-secret.env".content = ''
        WOODPECKER_AGENT_SECRET=${config.sops.placeholder."services/woodpecker/agent_secret"}
      '';

      "woodpecker-server-secrets.env".content = ''
        WOODPECKER_AGENT_SECRET=${config.sops.placeholder."services/woodpecker/agent_secret"}
        WOODPECKER_GITEA_SECRET=${config.sops.placeholder."services/woodpecker/forgejo_secret"}
      '';
    };
  };

  services = {
    woodpecker-server = {
      enable = true;
      environment = {
        WOODPECKER_HOST = "https://git.cyperpunk.de/ci";
        WOODPECKER_GITEA = "true";
        WOODPECKER_GITEA_URL = "https://git.cyperpunk.de";
        WOODPECKER_GITEA_CLIENT = "3029bdbf-42d4-4b6a-a4e7-c7fc6f9c0313";
        WOODPECKER_OPEN = "true";
        WOODPECKER_GRPC_ADDR = ":9003";
        WOODPECKER_SERVER_ADDR = ":8002";
      };
      environmentFile = [
        config.sops.templates."woodpecker-server-secrets.env".path
      ];
    };

    woodpecker-agents.agents = {
      "docker" = {
        enable = true;
        extraGroups = [ "docker" ];
        environment = {
          WOODPECKER_SERVER = "localhost:9003";
          WOODPECKER_BACKEND = "docker";
          WOODPECKER_HEALTHCHECK_ADDR = ":3001";
        };
        environmentFile = [
          config.sops.templates."woodpecker-agent-secret.env".path
        ];
      };

      "exec" = {
        enable = true;
        environment = {
          WOODPECKER_SERVER = "localhost:9003";
          WOODPECKER_BACKEND = "local";
          WOODPECKER_HEALTHCHECK_ADDR = ":3001";
        };
        environmentFile = [
          config.sops.templates."woodpecker-agent-secret.env".path
        ];
        path = with pkgs; [
          bash
          coreutils
          git
          gitMinimal
          git-lfs
          nix
          openssh
          nixos-rebuild
          woodpecker-plugin-git
        ];
      };
    };
  };

  networking.firewall.allowedTCPPorts = [
    8002
  ];
}
