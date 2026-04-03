{ pkgs, ... }:
{
  # nvim-lint: Asynchronous linter that runs external linting tools
  # to find errors and style issues without blocking the editor.
  # Runs automatically after saving files.
  programs.nixvim = {
    plugins.lint = {
      enable = true;

      # Configure linters for each filetype
      lintersByFt = {
        lua = [ "luacheck" ];
        nix = [ "statix" ]; # Nix static analyzer
        python = [ "ruff" ];
        javascript = [ "eslint" ];
        rust = [ "clippy" ];
        # rasi has no common linter
      };

      # Trigger linting after saving a file
      autoCmd = {
        event = [ "BufWritePost" ];
        callback = {
          __raw = ''
            function()
              require('lint').try_lint()
            end
          '';
        };
      };
    };

    # Install linter binaries
    extraPackages = with pkgs; [
      lua54Packages.luacheck
      statix
      ruff
      nodePackages.eslint
      clippy
    ];
  };
}
