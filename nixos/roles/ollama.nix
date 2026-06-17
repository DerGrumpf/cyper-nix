_: {
  services.ollama = {
    enable = true;

    host = "0.0.0.0";
    port = 11434;

    openFirewall = true;

    loadModels = [
      "llama3.2:3b"
      "qwen2.5:3b"
      "deepseek-r1:1.5b"
    ];

    syncModels = true;

    environmentVariables = {
      OLLAMA_CONTEXT_LENGTH = "16384";
    };
  };
}
