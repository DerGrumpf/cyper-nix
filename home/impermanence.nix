{
  home.persistence."/persist/home" = {
    hideMounts = true;
    directories = [
      ".config/nix"
      "Documents"
      "Downloads"
      "Pictures"
    ];
  };
}
