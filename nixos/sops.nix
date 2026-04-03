{ primaryUser, ... }:
{
  sops = {
    defaultSopsFile = ../secrets/secrets.yaml;
    defaultSopsFormat = "yaml";
    age.keyFile = "/home/phil/.config/sops/age/keys.txt";

    secrets = {
      GROQ_API_KEY = { };
      OPENWEATHER_API_KEY = { };
      ssh_private_key = {
        path = "/home/${primaryUser}/.ssh/ssh";
        owner = primaryUser;
        mode = "0600";
      };
    };
  };
}
