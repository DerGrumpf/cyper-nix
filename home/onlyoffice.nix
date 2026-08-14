{ pkgs, isDarwin, ... }: {
  programs.onlyoffice = pkgs.lib.mkIf (!isDarwin) { enable = true; };
}
