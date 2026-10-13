{ lib, primaryUser, ... }:
{
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    settings = {
      "*" = {
        AddKeysToAgent = "yes";
      };
      "*.cyperpunk.de" = {
        IdentityFile = "/Users/${primaryUser}/.ssh/ssh";
        User = primaryUser;
      };
      "github.com" = {
        IdentityFile = "/Users/${primaryUser}/.ssh/github";
        User = "git";
      };
      "git.rz.tu-bs.de" = {
        IdentityFile = "/Users/${primaryUser}/.ssh/github";
        User = "git";
      };
      "git.cyperpunk.de" = lib.hm.dag.entryBefore [ "*.cyperpunk.de" ] {
        HostName = "git.cyperpunk.de";
        Port = 12222;
        User = "forgejo";
        IdentityFile = "/Users/${primaryUser}/.ssh/ssh";
      };
    };
  };
}
