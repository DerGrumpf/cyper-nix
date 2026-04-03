{ pkgs, ... }:
{
  # ToggleTerm: Terminal emulator inside Neovim
  # Provides floating, horizontal, and vertical terminal windows.
  programs.nixvim.plugins.toggleterm = {
    enable = true;

    settings = {
      size = 20;
      open_mapping = "[[<c-\\>]]";
      direction = "float";
      float_opts = {
        border = "single";
        width = 200;
        height = 40;
      };
    };
  };

  programs.nixvim.keymaps = [
    {
      mode = "n";
      key = "<leader>h";
      action.__raw = ''
        function()
          require("toggleterm").toggle(1, 10, vim.loop.cwd(), "horizontal")
        end
      '';
      options.desc = "Toggle terminal (horizontal)";
    }
    {
      mode = "n";
      key = "<leader>v";
      action.__raw = ''
        function()
          require("toggleterm").toggle(2, 60, vim.loop.cwd(), "vertical")
        end
      '';
      options.desc = "Toggle terminal (vertical)";
    }
    {
      mode = "n";
      key = "<leader>ft";
      action.__raw = ''
        function()
          require("toggleterm").toggle(3, 20, vim.loop.cwd(), "float")
        end
      '';
      options.desc = "Toggle terminal (float)";
    }
    {
      mode = "t";
      key = "<C-t>";
      action = "<Cmd>ToggleTerm<CR>";
      options.desc = "Toggle terminal";
    }
    {
      mode = "t";
      key = "<C-v>";
      action = "<C-\\><C-n>v";
      options.desc = "Exit terminal and enter visual mode";
    }
  ];
}
