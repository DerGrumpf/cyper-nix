{ pkgs, ... }: {
  # Alpha: Start screen/dashboard for Neovim
  # Shows a custom ASCII art header and quick action buttons on startup.
  programs.nixvim.plugins.alpha = {
    enable = true;
    settings.layout = [
      {
        type = "padding";
        val = 2;
      }
      {
        type = "text";
        val = [
          "⣿⣿⣿⣿⣿⣿⣿⣿⣿⢿⣯⣿⠿⣟⣷⣯⣛⢿⣿⣿⣾⣟⣿⣿⣿⣿⣿⣿⣿⣿⣿"
          "⣿⣿⣿⣿⣿⣿⣿⡿⣵⣿⡿⣴⣽⡟⣳⢿⢽⣽⣕⣽⢿⡿⣿⣟⣿⣿⣿⣿⣿⣿⣿"
          "⣿⣿⣿⣷⣿⣿⢟⣫⣿⢟⢟⣾⣾⣿⣿⣞⢳⣻⢞⣎⠿⢞⣊⣿⣞⣿⣿⣿⣿⣿⢽"
          "⣿⣿⣿⣿⣿⣏⢯⣿⣏⣏⠔⢇⣿⢢⢆⢀⢆⣧⣼⢻⢰⡧⢻⣝⣏⡸⣧⣾⣿⣿⣿"
          "⣿⣿⣿⣿⡟⣻⣿⣿⡾⡿⡼⢸⡝⣝⡳⢢⣧⢳⣳⢷⡇⣗⢺⡺⣿⡧⣿⣿⣿⢿⢿"
          "⣿⡿⣿⣼⡼⣿⣿⡗⡧⣧⠁⡝⣧⣳⠅⡾⠈⣎⢮⣧⣿⣿⣗⣷⣻⢷⣏⣼⢏⣺⣿"
          "⣿⣿⣿⣻⣿⣿⣿⢧⣿⢹⠉⢷⢿⣧⣲⡏⡀⡈⢆⠳⣿⡿⢿⣿⣱⢿⢫⣷⣝⣿⣿"
          "⣿⣿⣿⡯⡟⣿⣿⢽⣡⠟⢿⣮⠁⠙⠛⠈⡴⢿⣿⡷⣬⣽⢽⠧⣷⡏⣿⡇⣧⣽⣿"
          "⣿⠟⢻⡧⡇⣿⡇⣇⣆⢄⡜⢃⡀⡀⡀⡀⡀⢎⣁⠁⣸⣗⣸⣿⣧⣼⡿⢹⢿⢾⣿"
          "⣿⣷⣾⣿⢻⣿⢧⢻⣽⡀⡀⡀⡀⢄⡀⡀⡀⡀⡀⢀⣷⡸⡟⣿⣶⣻⣧⡛⡱⢝⣿"
          "⣿⣿⣿⣿⢸⡿⢚⡜⣿⣇⡀⡀⡀⡀⡀⡀⡀⡀⠚⢁⢣⣜⡿⣿⡇⢼⣿⠨⣸⣿⣿"
          "⣿⣄⣿⣗⢾⢻⣧⢿⣾⣿⣦⡀⡀⠑⠚⠉⡀⡀⣤⣿⢨⣿⠗⣻⢣⣿⢹⢈⣽⣿⣿"
          "⣿⣿⣿⣿⢎⡄⢿⣞⡇⣿⠹⣿⣶⣀⡀⣀⡴⡩⢸⢏⣿⣿⣶⢻⣾⢏⡞⠡⢽⣇⣾"
          "⣿⣿⣿⣮⣼⢬⣦⢿⣳⣌⠧⡉⠈⣇⣛⣁⣈⣼⣿⡸⠫⠛⠐⠛⠕⣙⣻⣬⣼⣿⣿"
          "⢟⢿⣿⣿⣿⡢⣃⣪⣭⣡⣤⣶⠟⡿⠿⠿⠿⠛⢁⣿⣿⢩⠉⡀⠈⠓⡝⣿⣿⣿⣿"
          "⣾⣿⣿⣿⣿⠞⢔⡣⡴⣾⣿⠓⣤⢧⡼⣉⠠⢤⣿⣿⠇⠃⡀⡀⡀⡀⡸⢿⣾⣿⣿"
          "⣿⣿⣿⡿⣺⡸⢗⢠⣇⣿⣿⠊⠃⡀⠉⡀⢠⣿⣿⠟⡸⡀⡀⡀⡀⡀⣃⣬⠽⠿⣿"
          "⣿⣿⣿⣿⡇⡏⢸⣿⠟⣽⡇⡀⡀⡀⡀⣴⣟⢭⣾⣿⡇⠎⣠⠒⠉⠈⢀⡀⢨⡋⣿"
          "⠛⠛⠛⠋⠃⠓⠚⠛⠘⠛⠃⡀⠊⡀⠛⠛⠛⠂⠛⠛⠓⠁⠚⡀⠂⠒⠒⠐⠒⠋⠛"
        ];
        opts = {
          position = "center";
          hl = "Type";
        };
      }
      {
        type = "padding";
        val = 2;
      }
      {
        type = "group";
        val = [
          {
            type = "button";
            val = "[+] New file";
            on_press.__raw =
              "function() vim.cmd[[ene]] vim.cmd[[startinsert]] end";
            opts = {
              keymap = [ "n" "e" ":ene <BAR> startinsert <CR>" { } ];
              shortcut = "e";
              position = "center";
              cursor = 3;
              width = 50;
              align_shortcut = "right";
              hl_shortcut = "Keyword";
            };
          }
          {
            type = "button";
            val = "[?] Find file";
            on_press.__raw = "function() vim.cmd[[Telescope find_files]] end";
            opts = {
              keymap = [ "n" "f" ":Telescope find_files <CR>" { } ];
              shortcut = "f";
              position = "center";
              cursor = 3;
              width = 50;
              align_shortcut = "right";
              hl_shortcut = "Keyword";
            };
          }
          {
            type = "button";
            val = "[~] Recent files";
            on_press.__raw = "function() vim.cmd[[Telescope oldfiles]] end";
            opts = {
              keymap = [ "n" "r" ":Telescope oldfiles <CR>" { } ];
              shortcut = "r";
              position = "center";
              cursor = 3;
              width = 50;
              align_shortcut = "right";
              hl_shortcut = "Keyword";
            };
          }
          {
            type = "button";
            val = "[Y] Yazi";
            on_press.__raw = "function() require('yazi').yazi() end";
            opts = {
              keymap = [ "n" "y" ":Yazi<CR>" { } ];
              shortcut = "y";
              position = "center";
              cursor = 3;
              width = 50;
              align_shortcut = "right";
              hl_shortcut = "Keyword";
            };
          }
          {
            type = "button";
            val = "[A] Open Prompt";
            #on_press.__raw = "function() require('yazi').yazi() end";
            opts = {
              keymap = [ "n" "a" ":AvanteChatNew<CR>" { } ];
              shortcut = "a";
              position = "center";
              cursor = 3;
              width = 50;
              align_shortcut = "right";
              hl_shortcut = "Keyword";
            };
          }
          {
            type = "button";
            val = "[X] Quit";
            on_press.__raw = "function() vim.cmd[[qa]] end";
            opts = {
              keymap = [ "n" "q" ":qa<CR>" { } ];
              shortcut = "q";
              position = "center";
              cursor = 3;
              width = 50;
              align_shortcut = "right";
              hl_shortcut = "Keyword";
            };
          }
        ];
      }
      {
        type = "padding";
        val = 2;
      }
      {
        type = "text";
        val = "Circuits hum in anticipation of your will.";
        opts = {
          position = "center";
          hl = "Comment";
        };
      }
    ];
  };
}
