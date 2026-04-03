{ pkgs, ... }:
{

  # Install language parsers declaratively
  # Syntax Highlighting
  programs.nixvim.plugins.treesitter = {
    enable = true;
    grammarPackages = with pkgs.vimPlugins.nvim-treesitter.builtGrammars; [
      lua
      nix
      python
      javascript
      rust
      rasi
    ];

    settings = {
      highlight = {
        enable = true;
        additional_vim_regex_highlighting = false;
      };
    };
  };
}
