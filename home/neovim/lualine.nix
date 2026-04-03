{ pkgs, ... }:
{
  # Lualine: Fast and customizable statusline for Neovim
  # Displays file info, git status, diagnostics, and mode at the bottom of the editor.
  programs.nixvim.plugins.lualine = {
    enable = true;

    settings = {
      options = {
        theme = "catppuccin";
        component_separators = {
          left = "|";
          right = "|";
        };
        section_separators = {
          left = "";
          right = "";
        };
      };
    };
  };
}
