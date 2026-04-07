{ primaryUser, isDarwin, ... }:
{
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    matchBlocks = {
      "*" = {
        addKeysToAgent = "yes";
      };
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
