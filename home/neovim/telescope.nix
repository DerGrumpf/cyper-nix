{ pkgs, ... }:
{
  # Telescope: Fuzzy finder for files, buffers, grep, and more
  # Provides fast search and navigation throughout your project.
  programs.nixvim.plugins.telescope = {
    enable = true;

    keymaps = {
      "<leader>ff" = {
        action = "find_files";
        options.desc = "Telescope find files";
      };
      "<leader>fg" = {
        action = "live_grep";
        options.desc = "Telescope live grep";
      };
      "<leader>fb" = {
        action = "buffers";
        options.desc = "Telescope buffers";
      };
      "<leader>fh" = {
        action = "help_tags";
        options.desc = "Telescope help tags";
      };
    };
  };
}
