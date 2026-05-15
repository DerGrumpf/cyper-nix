_: {
  programs.nixvim = {
    plugins.diffview = {
      enable = true;
      keymaps = {
        "]x" = "<cmd>DiffviewConflictNext<CR>";
        "[x" = "<cmd>DiffviewConflictPrev<CR>";
        "do" = "<cmd>DiffviewFocusOurs<CR>";
        "dt" = "<cmd>DiffviewFocusTheirs<CR>";
      };
    };
  };
}
