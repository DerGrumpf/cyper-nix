{ pkgs, ... }:
{
  # Conform: Code formatter that runs external formatting tools
  # Automatically formats code on save for consistent style.
  programs.nixvim = {
    plugins.conform-nvim = {
      enable = true;

      settings = {
        formatters_by_ft = {
          lua = [ "stylua" ];
          nix = [ "nixfmt" ];
          python = [ "black" ];
          rust = [ "rustfmt" ];
          rasi = [ "prettierd" ];
        };

        format_on_save = {
          timeout_ms = 2000;
          lsp_fallback = true;
        };
      };
    };

    # Install formatters
    extraPackages = with pkgs; [
      stylua
      nixfmt
      black
      rustfmt
      prettierd
    ];
  };
}
