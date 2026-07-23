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
          c = [ "clang_format" ];
          cpp = [ "clang_format" ];
        };

        formatters.clang_format = {
          # If the file has a project .clang-format (walking up from the
          # file itself, not nvim's cwd), use it - this is how a real
          # kernel checkout, or any other C/C++ project's own style,
          # gets respected automatically. Otherwise fall back to an
          # inline approximation of kernel style instead of plain LLVM,
          # since that's the sane default for one-off C files.
          prepend_args = {
            __raw = ''
              function(self, ctx)
                local found = vim.fs.find(
                  { ".clang-format", "_clang-format" },
                  { path = ctx.filename, upward = true }
                )[1]
                if found then
                  return { "-style=file" }
                end
                return {
                  "-style={BasedOnStyle: LLVM, IndentWidth: 8, UseTab: Always, "
                  .. "TabWidth: 8, BreakBeforeBraces: Linux, ColumnLimit: 80, "
                  .. "IndentCaseLabels: false, PointerAlignment: Right, "
                  .. "DerivePointerAlignment: false, SpaceBeforeParens: ControlStatements, "
                  .. "SpacesInParentheses: false, SpaceAfterCStyleCast: false, "
                  .. "AllowShortIfStatementsOnASingleLine: false, AllowShortBlocksOnASingleLine: false, "
                  .. "AllowShortFunctionsOnASingleLine: None, AllowShortLoopsOnASingleLine: false, "
                  .. "ReflowComments: false}"
                }
              end
            '';
          };
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
      clang-tools # provides clang-format
    ];
  };
}
