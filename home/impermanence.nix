{ primaryUser, ... }:
{
  home.persistence."/persist/home/${primaryUser}" = {
    hideMounts = true;
    directories = [
      ".config/nix"
      ".local/share/zoxide"
      "Documents"
      "Downloads"
      "Pictures"
    ];
    files = [
      ".local/share/fish/fish_history"
    ];
  };
}
