{
  inputs,
  ...
}:
{
  imports = [ inputs.catppuccin.homeModules.catppuccin ];

  catppuccin = {
    accent = "red";
    flavor = "mocha";
    eza.enable = true;
    fzf.enable = true;
    bat.enable = true;
    element-desktop = {
      enable = true;
      accent = "green";
    };
    btop.enable = true;
    cava = {
      enable = true;
      transparent = true;
    };
    kitty.enable = true;
    lazygit.enable = true;
    yazi.enable = true;
    fish.enable = true;
    opencode.enable = true;
  };
}
