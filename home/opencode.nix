_: {
  programs.opencode = {
    enable = true;

    settings = {
      enabled_providers = [ "ollama" ];

      model = "ollama/llama3.2:3b";

      provider = {
        ollama = {
          npm = "@ai-sdk/openai-compatible";
          name = "Ollama (tailscale)";
          options = {
            baseURL = "http://100.109.179.25:11434/v1";
          };
          models = {
            "llama3.2:3b" = {
              name = "Llama 3.2 3B";
            };
            "qwen2.5:3b" = {
              name = "Qwen 2.5 3B";
            };
            "deepseek-r1:1.5b" = {
              name = "DeepSeek-R1 1.5B";
            };
            "gemma4:e2b" = {
              name = "Gemma 4 2B Edge";
            };
          };
        };
      };
    };
  };
}
