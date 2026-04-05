{ primaryUser, ... }:
{
  services.openssh = {
    enable = true;
    openFirewall = true;
    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "no";
    };
  };
  users.users.${primaryUser}.openssh.authorizedKeys.keyFiles = [ ../secrets/ssh-key ];
  programs.ssh.startAgent = true;

}
