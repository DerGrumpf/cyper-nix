{ primaryUser, pkgs, ... }: {

  home.packages = with pkgs; [ gh gnupg ];

  programs = {
    git = {
      enable = true;
      settings = {
        github = { user = primaryUser; };
        init = { defaultBranch = "main"; };
        user = {
          name = "DerGrumpf"; # TODO replace
          email = "phil.keier@hotmail.com"; # TODO replace
        };
      };

      lfs.enable = true;
      ignores = [ "**/.DS_STORE" "result" ];
    };
    lazygit = { enable = true; };
  };
}
