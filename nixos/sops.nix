{ primaryUser, ... }:
{
  sops = {
    defaultSopsFile = ../secrets/secrets.yaml;
    defaultSopsFormat = "yaml";
    age.keyFile = "/home/${primaryUser}/.config/nix/secrets/keys.txt";
    secrets = {
      grafana_secret_key = {
        owner = "grafana";
      };
    };
  };
}
