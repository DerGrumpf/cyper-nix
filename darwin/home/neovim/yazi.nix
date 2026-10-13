{ pkgs, ... }: {
  # Yazi: Terminal file manager integration for Neovim
  # Provides a fast, visual way to browse and manage files.
  programs.nixvim = {
    # Use extraPlugins to manually load yazi.nvim
    extraPlugins = with pkgs.vimPlugins; [ yazi-nvim ];

    # Configure yazi after it's loaded
    extraConfigLua = ''
      require('yazi').setup({
        open_for_directories = true,
      })
    '';

    keymaps = [
      {
        mode = "n";
        key = "<leader>fy";
        action.__raw = ''
          function()
            require('yazi').yazi(nil, vim.loop.cwd())
          end
        '';
        options.desc = "Open Yazi file manager";
      }
      {
        mode = "n";
        key = "<leader>fd";
        action.__raw = ''
          function()
            require('yazi').yazi(nil, vim.fn.expand("%:p:h"))
          end
        '';
        options.desc = "Open Yazi in current file directory";
      }
    ];

    # Install yazi terminal program
    extraPackages = with pkgs; [ yazi ];
  };
}
