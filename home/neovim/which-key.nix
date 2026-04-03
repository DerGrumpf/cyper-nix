{ pkgs, ... }: {
  # Which-key: Display available keybindings in popup
  # Shows all possible key combinations after pressing leader or other prefix keys
  programs.nixvim.plugins.which-key = {
    enable = true;

    settings = {
      delay = 500; # Time in ms before popup shows

      icons = {
        breadcrumb = "»";
        separator = "➜";
        group = "+";
      };

      # Organize keymaps into named groups
      spec = [
        # Leader key groups
        {
          __unkeyed-1 = "<leader>a";
          group = "Avante AI";
          icon = "🤖";
        }
        {
          __unkeyed-1 = "<leader>f";
          group = "Find/Files/Terminal";
          icon = "🔍";
        }
        {
          __unkeyed-1 = "<leader>m";
          group = "Molten (Jupyter)";
          icon = "📓";
        }
        {
          __unkeyed-1 = "<leader>o";
          group = "OpenSCAD";
          icon = "🔧";
        }

        # Bracket navigation groups
        {
          __unkeyed-1 = "[";
          group = "Previous";
          icon = "⬅️";
        }
        {
          __unkeyed-1 = "]";
          group = "Next";
          icon = "➡️";
        }

        # g prefix groups
        {
          __unkeyed-1 = "g";
          group = "Go/LSP";
          icon = "🎯";
        }
        {
          __unkeyed-1 = "gr";
          group = "LSP References/Rename";
          icon = "🔗";
        }
        {
          __unkeyed-1 = "gc";
          group = "Comments";
          icon = "💬";
        }

        # l prefix
        {
          __unkeyed-1 = "<leader>l";
          group = "Live Server";
          icon = "🌐";
        }

        # z prefix
        {
          __unkeyed-1 = "z";
          group = "Folds/Spell";
          icon = "📋";
        }
      ];

      # Hide specific mappings to reduce clutter
      disable = {
        builtin_keys = {
          # Hide these default vim keys from which-key
          i = [ "<C-R>" "<C-W>" ];
          n = [ "<C-W>" ];
        };
      };
    };
  };
}
