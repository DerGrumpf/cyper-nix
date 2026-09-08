{ primaryUser, ... }:
{
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    settings = {
      "*" = {
        AddKeysToAgent = "yes";
      };
      "*.cyperpunk.de" = {
        IdentityFile = "/home/${primaryUser}/.ssh/ssh";
        User = primaryUser;
      };
      "github.com" = {
        IdentityFile = "/home/${primaryUser}/.ssh/github";
        User = "git";
      };
      "git.rz.tu-bs.de" = {
        IdentityFile = "/home/${primaryUser}/.ssh/github";
        User = "git";
      };
      "git.cyperpunk.de" = {
        HostName = "git.cyperpunk.de";
        Port = 12222;
        User = "gitea";
        IdentityFile = "/home/${primaryUser}/.ssh/ssh";
      };
    };
  };
}
