{ pkgs, ... }: {
  programs.onlyoffice =
    pkgs.lib.mkIf (!pkgs.stdenv.isDarwin) { enable = true; };
}
