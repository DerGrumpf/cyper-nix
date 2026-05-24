{ primaryUser, isDarwin, ... }:
{
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    settings = {
      "*" = {
        AddKeysToAgent = "yes";
      };

      "*.cyperpunk.de" = {
        IdentityFile =
          if isDarwin then "/Users/${primaryUser}/.ssh/ssh" else "/home/${primaryUser}/.ssh/ssh";
        User = primaryUser;
      };

      "github.com" = {
        IdentityFile =
          if isDarwin then "/Users/${primaryUser}/.ssh/github" else "/home/${primaryUser}/.ssh/github";
        User = "git";
      };

      "git.rz.tu-bs.de" = {
        IdentityFile =
          if isDarwin then "/Users/${primaryUser}/.ssh/github" else "/home/${primaryUser}/.ssh/github";
        User = "git";
      };

      "git.cyperpunk.de" = {
        HostName = "git.cyperpunk.de";
        Port = 12222;
        User = "gitea";
        IdentityFile =
          if isDarwin then "/Users/${primaryUser}/.ssh/ssh" else "/home/${primaryUser}/.ssh/ssh";
      };
    };
  };
}
