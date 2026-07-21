{ lib, isDarwin, ... }:
{
  home.persistence."/persist" = lib.mkIf (!isDarwin) {
    hideMounts = true;
    directories = [
      ".config/nix"
      "Documents"
      "Downloads"
      "Pictures"
      ".thunderbird"
      ".xonotic"
      ".config/Element"
      ".irssi"
      ".config/blender"
    ];
  };
}
