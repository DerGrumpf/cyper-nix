{ pkgs, ... }: {
  # Live Server: Auto-reload browser for web development
  # Uses browser-sync for live reload functionality
  programs.nixvim = {
    keymaps = [{
      mode = "n";
      key = "<leader>ls";
      action =
        "<cmd>terminal browser-sync start --server --files '*.html, *.css, *.js' --no-notify<cr>";
      options.desc = "Start live server (browser-sync)";
    }];

    extraPackages = with pkgs; [ nodePackages.browser-sync ];
  };
}
