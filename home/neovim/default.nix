{ pkgs, inputs, ... }:
{
  imports = [
    inputs.nixvim.homeModules.nixvim
    ./treesitter.nix
    ./lint.nix
    ./lsp.nix
    ./conform.nix
    ./lualine.nix
    ./yazi.nix
    ./toggleterm.nix
    ./telescope.nix
    ./catppuccin.nix
    ./alpha.nix
    #./avante.nix
    #./openscad.nix
    ./molten.nix
    ./which-key.nix
  ];

  home.packages = with pkgs; [
    nil
    biome
    #gdb
  ];

  programs.nixvim = {
    enable = true;
    defaultEditor = true;

    # Leader key
    globals.mapleader = " ";

    plugins.web-devicons.enable = true;

    opts = {
      number = true; # Show line numbers
      cursorline = true; # Highlight current line
      showmode = true; # already in statusline
      hlsearch = true; # Highlight search result
      incsearch = true; # Incremental Search
      tabstop = 4;
      termguicolors = true; # Enable 24-bit colormode
    };

    # Clipboard keymaps - yank to system clipboard
    keymaps = [
      # Yank operations
      {
        mode = "n";
        key = "y";
        action = ''"+y'';
        options.desc = "Yank to clipboard";
      }
      {
        mode = "v";
        key = "y";
        action = ''"+y'';
        options.desc = "Yank to clipboard";
      }
      {
        mode = "n";
        key = "Y";
        action = ''"+Y'';
        options.desc = "Yank line to clipboard";
      }
      # Delete operations
      {
        mode = "n";
        key = "d";
        action = ''"+d'';
        options.desc = "Delete to clipboard";
      }
      {
        mode = "v";
        key = "d";
        action = ''"+d'';
        options.desc = "Delete to clipboard";
      }
      {
        mode = "n";
        key = "D";
        action = ''"+D'';
        options.desc = "Delete line to clipboard";
      }
      # Paste operations
      {
        mode = "n";
        key = "p";
        action = ''"+p'';
        options.desc = "Paste from clipboard";
      }
      {
        mode = "v";
        key = "p";
        action = ''"+p'';
        options.desc = "Paste from clipboard";
      }
    ];
  };

}
