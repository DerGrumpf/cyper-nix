_: {
  programs.nixvim = {
    plugins.diffview = {
      enable = true;
      settings.keymaps.view = [
        {
          mode = "n";
          key = "]x";
          action = "<cmd>DiffviewConflictNext<CR>";
          description = "Next conflict";
        }
        {
          mode = "n";
          key = "[x";
          action = "<cmd>DiffviewConflictPrev<CR>";
          description = "Previous conflict";
        }
        {
          mode = "n";
          key = "do";
          action = "<cmd>DiffviewFocusOurs<CR>";
          description = "Focus ours";
        }
        {
          mode = "n";
          key = "dt";
          action = "<cmd>DiffviewFocusTheirs<CR>";
          description = "Focus theirs";
        }
      ];
    };
  };
}
