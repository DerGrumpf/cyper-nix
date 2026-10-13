{ primaryUser, ... }:
{
  sops = {
    defaultSopsFile = ../../secrets/secrets.yaml;
    defaultSopsFormat = "yaml";
    age.keyFile = "/Users/${primaryUser}/.config/nix/secrets/age-key.txt";
    secrets = {
      "ssh/private_key" = {
        path = "/Users/${primaryUser}/.ssh/ssh";
        mode = "0600";
      };
      "ssh/github_key" = {
        path = "/Users/${primaryUser}/.ssh/github";
        mode = "0600";
      };
    };
  };
}
