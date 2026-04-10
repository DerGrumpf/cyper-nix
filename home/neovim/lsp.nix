{ pkgs, ... }:
{
  # LSP configuration: Language Server Protocol provides IDE features
  # like autocomplete, go-to-definition, diagnostics, and more.
  programs.nixvim = {
    plugins = {
      # LSP configuration
      lsp = {
        enable = true;

        # Language servers for each language
        servers = {
          lua_ls = {
            enable = true;
            settings = {
              Lua = {
                runtime.version = "LuaJIT";
                diagnostics.globals = [ "vim" ];
                workspace.library = [ ]; # Populated by nixvim
                telemetry.enable = false;
              };
            };
          };

          nil_ls.enable = true; # Nix language server
          rust_analyzer = {
            enable = true; # Rust language server
            installCargo = true;
            installRustc = true;
          };
          pylsp.enable = true; # Python language server
        };

        # Keymaps for LSP actions
        keymaps = {
          diagnostic = {
            "<leader>e" = "open_float";
            "[d" = "goto_prev";
            "]d" = "goto_next";
          };
          lspBuf = {
            "gd" = "definition";
            "K" = "hover";
            "<leader>rn" = "rename";
            "<leader>ca" = "code_action";
          };
        };
      };

      # Autocompletion
      cmp = {
        enable = true;
        autoEnableSources = true;

        settings = {
          snippet.expand = ''
            function(args)
              require('luasnip').lsp_expand(args.body)
            end
          '';

          mapping = {
            "<C-b>" = "cmp.mapping.scroll_docs(-4)";
            "<C-f>" = "cmp.mapping.scroll_docs(4)";
            "<C-Space>" = "cmp.mapping.complete()";
            "<C-e>" = "cmp.mapping.abort()";
            "<CR>" = "cmp.mapping.confirm({ select = true })";
          };

          sources = [
            { name = "nvim_lsp"; }
            { name = "luasnip"; }
            { name = "buffer"; }
            { name = "path"; }
          ];
        };
      };

      # Snippet engine (required for completion)
      luasnip.enable = true;
    };

    # Install LSP servers
    extraPackages = with pkgs; [
      lua-language-server
      nil
      rust-analyzer
    ];
  };
}
