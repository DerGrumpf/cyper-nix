{ primaryUser, ... }:
{
  home.persistence."/persist/home/${primaryUser}" = {
    hideMounts = true;
    directories = [
      ".config/nix"
      "Documents"
      "Downloads"
      "Pictures"
    ];

  };
}
