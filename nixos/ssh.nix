_: {
  services.openssh = {
    enable = true;
    openFirewall = true;
    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "no";
    };
    authorizedKeys.keyFiles = [ ../secrets/ssh-key ];
  };

  programs.ssh.startAgent = true;

}
