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
    fcitx5.enable = false;
    forgejo.enable = false;
    gitea.enable = false;
    sddm.enable = false;
  };
}
