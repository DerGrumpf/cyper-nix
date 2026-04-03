{ pkgs, ... }:
{
  # Catppuccin: Soothing pastel theme for Neovim
  # Provides consistent theming across plugins with transparency support.
  programs.nixvim = {
    colorschemes.catppuccin = {
      enable = true;
      settings = {
        flavour = "mocha";
        transparent_background = true;
        term_colors = true;
        integrations = {
          treesitter = true;
          cmp = true;
          gitsigns = true;
          telescope = {
            enabled = true;
          };
          notify = true;
          mini = {
            enabled = true;
          };
        };
      };
    };

    # Custom highlight overrides
    extraConfigLua = ''
      local colors = require("catppuccin.palettes").get_palette("mocha")
      vim.api.nvim_set_hl(0, "LineNr", { fg = colors.text, bg = "NONE" })
      vim.api.nvim_set_hl(0, "CursorLineNr", { fg = colors.pink, bg = "NONE", bold = true })
    '';
  };
}
