{ pkgs, ... }: {
  home.packages = with pkgs; [
    typst
    typstyle
  ];
  programs.nixvim = {
    plugins = {
      typst-vim = {
        enable = true;
        keymaps.watch = "<leader>tw";
      };
      typst-preview = {
        enable = true;
        settings = { };
      };
    };
    keymaps = [
      {
        mode = "n";
        key = "<leader>tp";
        action = "<cmd>TypstPreviewToggle<CR>";
        options.desc = "Toggle Typst preview";
      }
    ];
    extraConfigLua = ''
      vim.keymap.set("n", "<leader>tm", function()
        local main = vim.fn.findfile("main.typ", vim.fn.expand("%:p:h") .. ";")
        if main == "" then
          vim.notify("No main.typ found upward from current file", vim.log.levels.WARN)
          return
        end
        vim.lsp.buf.execute_command({
          command = "tinymist.pinMain",
          arguments = { vim.fn.fnamemodify(main, ":p") },
        })
        vim.notify("Pinned main.typ: " .. main)
      end, { desc = "Pin nearest main.typ (Typst)" })

      vim.keymap.set("n", "<leader>tu", function()
        vim.lsp.buf.execute_command({
          command = "tinymist.pinMain",
          arguments = { vim.NIL },
        })
        vim.notify("Unpinned Typst main file")
      end, { desc = "Unpin Typst main file" })
    '';
  };
}
