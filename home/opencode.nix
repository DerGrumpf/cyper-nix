{ config, ... }:
{
  sops = {
    secrets."system/nvidia" = { };
    templates."nvidia-api-key".content = config.sops.placeholder."system/nvidia";
  };

  programs.opencode = {
    enable = true;
    settings = {
      enabled_providers = [
        "nvidia"
      ];
      model = "nvidia/nemotron-3-ultra-550b-a55b";
      provider = {
        nvidia = {
          npm = "@ai-sdk/openai-compatible";
          name = "NVIDIA";
          env = [ "NVIDIA_API_KEY" ];
          options = {
            baseURL = "https://integrate.api.nvidia.com/v1";
            apiKey = "{env:NVIDIA_API_KEY}";
          };
          models = {
            "nvidia/nemotron-3-ultra-550b-a55b" = {
              name = "Nemotron 3 Ultra 550B A55B";
            };
          };
        };
      };
    };
  };
}
