{ pkgs, ... }: {
  # OpenSCAD: 3D modeling language support with syntax highlighting,
  # cheatsheet, snippets, offline manual and fuzzy help
  programs.nixvim = {
    plugins.openscad = {
      enable = true;
      autoLoad = true;
      settings = {
        fuzzy_finder = "fzf";
        auto_open = true;
        cheatsheet_toggle_key = "<leader>os";
        default_mappings = true;
        exec_openscad_trig_key = "<leader>oo";
        help_manual_trig_key = "<leader>om";
        help_trig_key = "<leader>oh";
        top_toggle = "<leader>oc";

      };
    };

    # Install OpenSCAD binary for preview/compilation
    extraPackages = with pkgs; [
      openscad
      zathura # PDF viewer for manual
      fzf
    ];
  };
}
