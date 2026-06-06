{
  pkgs,
  isDarwin,
  lib,
  ...
}:
let
  fonts = with pkgs; [
    nerd-fonts.fira-code
    nerd-fonts.fira-mono
    nerd-fonts.hack
  ];
in
{
  fonts.fontconfig.enable = true;
  home = {
    packages = lib.mkIf (!isDarwin) fonts;

    file = lib.mkIf isDarwin (
      builtins.listToAttrs (
        builtins.concatMap (
          pkg:
          map (file: {
            name = "Library/Fonts/${builtins.baseNameOf file}";
            value = {
              source = file;
            };
          }) (lib.filesystem.listFilesRecursive "${pkg}/share/fonts")
        ) fonts
      )
    );
  };
}
