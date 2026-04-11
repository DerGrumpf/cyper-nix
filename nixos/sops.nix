{ primaryUser, ... }:
{
  sops = {
    defaultSopsFile = ../secrets/secrets.yaml;
    defaultSopsFormat = "yaml";
    age.keyFile = "/home/${primaryUser}/.config/nix/secrets/keys.txt";
    secrets = {
      grafana_secret_key = {
        owner = "grafana";
        group = "grafana";
      };
      matrix_macaroon_secret = { };
      matrix_registration_secret = {
        owner = "matrix-synapse";
        group = "matrix-synapse";
      };
    };
  };
}
