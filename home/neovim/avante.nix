{ pkgs, ... }:
{
  # Avante: AI-powered coding assistant (Cursor-like experience in Neovim)
  programs.nixvim = {
    plugins = {
      markdown-preview.enable = true;
      render-markdown.enable = true;
      avante = {
        enable = true;
        autoLoad = true;
        settings = {
          provider = "ollama";

          providers = {
            groq = {
              __inherited_from = "openai";
              api_key_name = "cmd:cat /home/phil/.config/sops-nix/secrets/GROQ_API_KEY";
              endpoint = "https://api.groq.com/openai/v1/";
              model = "qwen/qwen3-32b";
              system_promt = "You are a helpful coding assistant. Always respond in plain markdown format without using tool calls or JSON structures.";
              disable_tools = true;
              extra_request_body = {
                temperature = 1;
                max_tokens = 2000;
                response_format = {
                  type = "text";
                };
              };
            };

            ollama = {
              endpoint = "http://100.109.179.25:11434"; # tailscale IP, no /v1 suffix
              model = "qwen2.5:3b"; # swap for "llama3.2:3b" or "deepseek-r1:1.5b"
              timeout = 60000; # local + small model can be slow on first load
              disable_tools = true; # these small models aren't reliable at tool calling
              is_env_set.__raw = ''require("avante.providers.ollama").check_endpoint_alive'';
              extra_request_body = {
                options = {
                  temperature = 0.7;
                  num_ctx = 8192;
                  keep_alive = "5m";
                };
              };
            };
          };

          render = {
            markdown = true;
            syntax = true;
            heading = true;
            code = true;
            link = true;
          };
          behaviour = {
            enable_cursor_planning_mode = false;
            auto_suggestions = false;
            auto_set_highlight_group = true;
            auto_set_keymaps = true;
            auto_apply_diff_after_generation = false;
            support_paste_from_clipboard = false;
            use_selection_as_context = true;
            max_context_tokens = 2000;
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
    };
  };
}
