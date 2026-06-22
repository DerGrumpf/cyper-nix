{ inputs, ... }:
{
  imports = [ inputs.catppuccin.nixosModules.catppuccin ];

  catppuccin = {
    enable = true;
    autoEnable = false;
    accent = "sky";
    flavor = "mocha";
    cache.enable = true;
    cursors = {
      enable = true;
      accent = "sapphire";
    };
  };
}
