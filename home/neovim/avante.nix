{ pkgs, ... }:
{
  # Avante: AI-powered coding assistant (Cursor-like experience in Neovim)
  programs.nixvim = {
    plugins = {
      markdown-preview.enable = true;
      render-markdown.enable = true;
      #extraConfigLuaPre = ''
      #  vim.env.GROQ_API_KEY = os.getenv("GROQ_API_KEY")
      #'';
      # TODO: Integrate CoPilot https://github.com/settings/copilot/features
      avante = {
        enable = true;
        autoLoad = true;
        settings = {
          provider = "groq";

          providers.groq = {
            __inherited_from = "openai";
            api_key_name = "GROQ_API_KEY";
            endpoint = "https://api.groq.com/openai/v1/";
            model = "llama-3.3-70b-versatile";
            disable_tools = true;
            extra_request_body = {
              temperature = 1;
              max_tokens = 8192;
              tools = null;
              tool_choice = "none";
            };
          };

          #        auto_suggestions_provider = "copilot";

          render = {
            markdown = true;
          };

          behaviour = {
            auto_suggestions = false;
            auto_set_highlight_group = true;
            auto_set_keymaps = true;
            auto_apply_diff_after_generation = false;
            support_paste_from_clipboard = false;
          };

          mappings = {
            ask = "<leader>aa";
            edit = "<leader>ae";
            refresh = "<leader>ar";
            diff = {
              ours = "co";
              theirs = "ct";
              all_theirs = "ca";
              both = "cb";
              cursor = "cc";
              next = "]x";
              prev = "[x";
            };
            suggestion = {
              accept = "<M-l>";
              next = "<M-]>";
              prev = "<M-[>";
              dismiss = "<C-]>";
            };
            jump = {
              next = "]]";
              prev = "[[";
            };
            submit = {
              normal = "<CR>";
              insert = "<C-s>";
            };
            sidebar = {
              switch_windows = "<Tab>";
              reverse_switch_windows = "<S-Tab>";
            };
          };

          hints = {
            enabled = true;
          };

          windows = {
            position = "right";
            wrap = true;
            width = 30;
            sidebar_header = {
              align = "center";
              rounded = true;
            };
          };

          highlights = {
            diff = {
              current = "DiffText";
              incoming = "DiffAdd";
            };
          };

          diff = {
            autojump = true;
            list_opener = "copen";
          };
        };
      };

      extraPackages = with pkgs; [ curl ];
    };
  };
}
