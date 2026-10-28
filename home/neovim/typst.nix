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
        settings = {
          get_main_file.__raw = ''
            function(path_of_buffer)
              local dir = vim.fs.dirname(path_of_buffer)
              local found = vim.fs.find("main.typ", { path = dir, upward = true })
              if found and found[1] then
                return found[1]
              end
              return path_of_buffer
            end
          '';
        };
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
  };
}
