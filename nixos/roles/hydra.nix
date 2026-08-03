{
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
      allowed-uris = [ "git+https://git.cyperpunk.de/" ];
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
      '';
    };
  };

  networking.firewall.allowedTCPPorts = [ 3000 ];
}
