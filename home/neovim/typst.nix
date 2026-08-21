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
  };
}
