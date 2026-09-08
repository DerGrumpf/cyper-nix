{ ... }:
{
  home.persistence."/persist" = {
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
      ".local/state/wireplumber"
      ".local/state/waypaper"
      ".cache/awww"
    ];
  };
}
