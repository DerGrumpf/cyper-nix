{ config, ... }:
{
  sops.secrets."system/nvidia" = { };

  programs.nixvim = {
    plugins = {
      markdown-preview.enable = true;
      render-markdown.enable = true;
      avante = {
        enable = true;
        autoLoad = true;
        settings = {
          provider = "nvidia";
          providers = {
            nvidia = {
              __inherited_from = "openai";
              api_key_name = "cmd:cat ${config.sops.secrets."system/nvidia".path}";
              endpoint = "https://integrate.api.nvidia.com/v1";
              model = "nvidia/nemotron-3-ultra-550b-a55b";
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
