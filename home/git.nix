{
  primaryUser,
  pkgs,
  ...
}:
{

  home = {
    packages = with pkgs; [
      gh
      gnupg
      tea
    ];

    persistence."/persist".directories = [
      ".config/gh"
      ".gnupg"
    ];
  };

  programs = {
    git = {
      enable = true;
      settings = {
        github = {
          user = primaryUser;
        };
        init = {
          defaultBranch = "main";
        };
        user = {
          name = "DerGrumpf";
          email = "phil.keier@hotmail.com";
        };
      };

      lfs.enable = true;
      ignores = [
        "**/.DS_STORE"
        "result"
      ];
    };

    lazygit = {
      enable = true;
    };

  };
}
