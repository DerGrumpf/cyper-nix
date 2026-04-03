{ pkgs, ... }: {
  programs.nixvim = {
    plugins.molten = {
      enable = true;
      python3Dependencies = p:
        with p; [
          pynvim
          jupyter-client
          cairosvg
          ipython
          nbformat
          ipykernel
          pnglatex
          plotly
          kaleido
          pyperclip
        ];
      settings = {
        kernel_name = "python3";
        auto_open_output = true;
        output_win_max_width = 80;
        output_win_max_height = 20;
      };
    };

    keymaps = [
      {
        mode = "n";
        key = "<leader>ml";
        action = "<cmd>MoltenEvaluateLine<CR>";
        options.desc = "Molten: Evaluate line";
        options.silent = true;
      }
      {
        mode = "v";
        key = "<leader>mv";
        action = "<Cmd>MoltenEvaluateVisual<CR>";
        options.desc = "Molten: Evaluate selection";
        options.silent = true;
      }
    ];
  };
}
