{ primaryUser, isDarwin, ... }:
{
  ssh = {
    enable = true;
    matchBlock = {
      "*.cyperpunk.de" = {
        identityFile =
          if isDarwin then "/Users/${primaryUser}/.ssh/ssh" else "/home/${primaryUser}/.ssh/ssh";
        user = primaryUser;
      };
      "github.com" = {
        identityFile =
          if isDarwin then "/Users/${primaryUser}/.ssh/github" else "/home/${primaryUser}/.ssh/github";
        user = "git";
      };
    };
  };
}
