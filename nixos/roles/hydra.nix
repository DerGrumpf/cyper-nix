{ config, ... }:
{
  sops = {
    secrets = {
      "services/hydra/forgejo_webhook_secret" = {
        owner = "hydra";
        mode = "0440";
      };
      "services/hydra/github_webhook_secret" = {
        owner = "hydra";
        mode = "0440";
      };
    };

    templates."hydra-webhook-secrets.conf" = {
      owner = "hydra";
      mode = "0440";
      content = ''
        <gitea>
          secret = ${config.sops.placeholder."services/hydra/forgejo_webhook_secret"}
        </gitea>
        <github>
          secret = ${config.sops.placeholder."services/hydra/github_webhook_secret"}
        </github>
      '';
    };

  };

  nix = {
    buildMachines = [
      {
        hostName = "localhost";
        system = "x86_64-linux";
        supportedFeatures = [
          "kvm"
          "nixos-test"
          "big-parallel"
          "benchmark"
        ];
        maxJobs = 4;
      }
      {
        hostName = "localhost";
        system = "aarch64-linux";
        maxJobs = 2;
      }
    ];
    settings = {
      allowed-uris = [
        "git+https://git.cyperpunk.de/"
        "git+https://github.com/"
      ];
      allow-import-from-derivation = true;
    };
  };

  services = {
    hydra = {
      enable = true;
      hydraURL = "https://www.cyperpunk.de/hydra";
      notificationSender = "hydra@cyperpunk.de";
      port = 3000;
      useSubstitutes = true;
      logo = ./hydra.png;
      maxServers = 12;

      extraConfig = ''
                allow_import_from_derivation = true
        		gitTimeout = 600
                <webhooks>
                  Include ${config.sops.templates."hydra-webhook-secrets.conf".path}
                </webhooks>
      '';

      tracker = ''
        <link rel="stylesheet" href="https://www.cyperpunk.de/hydra-theme/mocha.css">
      '';
    };
  };

  networking.firewall.allowedTCPPorts = [ 3000 ];
}
