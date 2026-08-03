{
  nix.settings.allowed-uris = [ "git+https://git.cyperpunk.de/" ];

  services = {
    hydra = {
      enable = true;
      hydraURL = "https://cyperpunk.de/hydra";
      notificationSender = "hydra@cyperpunk.de";
      port = 3000;
      useSubstitutes = true;
      buildMachinesFiles = [ ];
      logo = ./hydra.png;
      maxServers = 12;
    };
  };

  networking.firewall.allowedTCPPorts = [ 3000 ];
}
