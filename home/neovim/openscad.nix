{ pkgs, ... }:
{
  # OpenSCAD: 3D modeling language support with syntax highlighting,
  # cheatsheet, snippets, offline manual and fuzzy help
  programs.nixvim = {
    plugins.openscad = {
      enable = true;
      autoLoad = true;
      settings = {
        fuzzy_finder = "fzf";
        auto_open = true;
        cheatsheet_toggle_key = "<Enter>";
        default_mappings = true;
        exec_openscad_trig_key = "<A-h>";
        help_manual_trig_key = "<A-m>";
        help_trig_key = "<A-o>";
        top_toggle = "<A-c>";
        viewer_path = "open";
      };
    };

    # Install OpenSCAD binary for preview/compilation
    extraPackages = with pkgs; [
      openscad
      fzf
    ];
  };

}
