{
  config,
  pkgs,
  primaryUser,
  ...
}:
let
  domain = "www.cyperpunk.de";
  basePath = "/jupyter/";
  port = 8000;
in
{
  sops.secrets."kanidm/jupyterhub_secret" = {
    owner = "root";
    group = "kanidm";
    mode = "0440";
  };

  environment.persistence."/persist".directories = [
    {
      directory = "/var/lib/jupyterhub";
      user = "root";
      group = "root";
      mode = "0750";
    }
    {
      # per-user notebook data, bind-mounted into each user's container
      directory = "/var/lib/jupyterhub-users";
      user = "root";
      group = "root";
      mode = "0750";
    }
  ];

  services = {
    jupyterhub = {
      enable = true;
      host = "0.0.0.0";
      inherit port;

      authentication = "oauthenticator.generic.GenericOAuthenticator";
      spawner = "dockerspawner.DockerSpawner";

      jupyterhubEnv = pkgs.python3.withPackages (
        p: with p; [
          jupyterhub
          dockerspawner
          oauthenticator
        ]
      );

      extraConfig = ''
        import subprocess, json, os

        # --- Auth: kanidm OIDC, no local Unix accounts involved at all ---
        with open("${config.sops.secrets."kanidm/jupyterhub_secret".path}") as f:
        		c.GenericOAuthenticator.client_secret = f.read().strip()

        c.GenericOAuthenticator.client_id = "jupyterhub"
        c.GenericOAuthenticator.oauth_callback_url = "https://${domain}${basePath}hub/oauth_callback"
        c.GenericOAuthenticator.authorize_url = "https://auth.cyperpunk.de/ui/oauth2"
        c.GenericOAuthenticator.token_url = "https://auth.cyperpunk.de/oauth2/token"
        c.GenericOAuthenticator.userdata_url = "https://auth.cyperpunk.de/oauth2/openid/jupyterhub/userinfo"
        c.GenericOAuthenticator.scope = ["openid", "profile", "email"]
        c.GenericOAuthenticator.username_claim = "preferred_username"
        c.GenericOAuthenticator.login_service = "Kanidm"

        # Any authenticated kanidm user is allowed in; gate real access via
        # the kanidm oauth2 scope-map (jupyterhub_users group) instead of
        # an allow-list here.
        c.Authenticator.allow_all = True
        c.Authenticator.admin_users = {"${primaryUser}"}

        # --- Path-based routing under www.cyperpunk.de/jupyter ---
        c.JupyterHub.base_url = "${basePath}"

        # --- Containers need to reach the hub, which runs directly on the
        # host (not in Docker) on the default bridge network. Resolve the
        # bridge gateway dynamically instead of hardcoding 172.17.0.1. ---
        bridge = json.loads(subprocess.check_output(["${pkgs.docker}/bin/docker", "network", "inspect", "bridge"]))
        c.JupyterHub.hub_connect_ip = bridge[0]["IPAM"]["Config"][0]["Gateway"]

        c.DockerSpawner.image = "localhost:9000/dergrumpf/cyper-jupyter:latest"
        c.DockerSpawner.network_name = "bridge"
        c.DockerSpawner.remove = True
        c.DockerSpawner.notebook_dir = "/home/jovyan/work"
        c.DockerSpawner.volumes = {
        		"/storage/internal/jupyter/{username}": "/home/jovyan/work"
        }

        def create_user_dir_hook(spawner):
        		path = f"/storage/internal/jupyter/{spawner.user.name}"
        		os.makedirs(path, exist_ok=True)
        		os.chown(path, 1000, 100)

        c.Spawner.pre_spawn_hook = create_user_dir_hook
      '';
    };

    kanidm.provision = {
      groups.jupyterhub_users = {
        members = [ primaryUser ];
      };

      systems.oauth2.jupyterhub = {
        displayName = "JupyterHub";
        originUrl = "https://www.cyperpunk.de/jupyter/hub/oauth_callback";
        originLanding = "https://www.cyperpunk.de/jupyter/";
        basicSecretFile = config.sops.secrets."kanidm/jupyterhub_secret".path;
        preferShortUsername = true;
        scopeMaps.jupyterhub_users = [
          "openid"
          "profile"
          "email"
        ];
      };
    };
  };

  systemd.services.jupyterhub = {
    after = [
      "docker.service"
      "storage-internal.mount"
    ];
    requires = [
      "docker.service"
      "storage-internal.mount"
    ];
  };

  networking.firewall = {
    allowedTCPPorts = [ port ];
    trustedInterfaces = [ "docker0" ];
  };
}
