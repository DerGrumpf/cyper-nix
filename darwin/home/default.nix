{
  primaryUser,
  ...
}:
{
  imports = [
    ./sketchybar
    ./shell.nix
    ./opencode.nix
    ./neovim
    ./floorp
    ./obsidian.nix
    ./sops.nix
    ./ssh.nix
    ./nixcord.nix
    ./spicetify.nix
    ./catppuccin.nix
  ];

  home = {
    username = primaryUser;
    homeDirectory = "/Users/${primaryUser}";
    enableNixpkgsReleaseCheck = false;
    stateVersion = "26.05";
  };

  programs = {
    home-manager.enable = true;
    fish.enable = true;
  };
}
