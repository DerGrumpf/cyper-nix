{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.gs1200-exporter;

  instanceOpts =
    { name, ... }:
    {
      options = {
        address = lib.mkOption {
          type = lib.types.str;
          description = "IP address or hostname of the GS1200 switch.";
          example = "192.168.1.3";
        };

        port = lib.mkOption {
          type = lib.types.port;
          default = 9934;
          description = "Port on which to expose Prometheus metrics.";
        };

        password = lib.mkOption {
          type = lib.types.nullOr lib.types.str;
          default = null;
          description = ''
            Password to log in to the GS1200 web interface.
            Use passwordFile instead to avoid storing the password in the Nix store.
          '';
        };

        passwordFile = lib.mkOption {
          type = lib.types.nullOr lib.types.path;
          default = null;
          description = ''
            Path to a file containing the password to log in to the GS1200 web interface.
            This is the recommended option as it avoids storing the password in the Nix store.
            Compatible with sops-nix and agenix.
          '';
          example = "/run/secrets/gs1200-password";
        };

        debug = lib.mkOption {
          type = lib.types.bool;
          default = false;
          description = "Enable debug logging. Logs are accessible via journalctl -u gs1200-exporter-<name>.";
        };

        verbose = lib.mkOption {
          type = lib.types.bool;
          default = false;
          description = "Enable verbose logging. Logs are accessible via journalctl -u gs1200-exporter-<name>.";
        };

        json = lib.mkOption {
          type = lib.types.bool;
          default = false;
          description = "Output logs in JSON format. Logs are accessible via journalctl -u gs1200-exporter-<name>.";
        };

        user = lib.mkOption {
          type = lib.types.str;
          default = "gs1200-exporter-${name}";
          description = "User under which the service runs.";
        };

        group = lib.mkOption {
          type = lib.types.str;
          default = "gs1200-exporter-${name}";
          description = "Group under which the service runs.";
        };
      };
    };

  mkService = name: icfg: {
    "gs1200-exporter-${name}" = {
      description = "Prometheus exporter for Zyxel GS1200 switch '${name}'";
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];

      serviceConfig = {
        User = icfg.user;
        Group = icfg.group;
        Restart = "always";
        RestartSec = "10s";

        # Hardening
        NoNewPrivileges = true;
        PrivateTmp = true;
        ProtectSystem = "strict";
        ProtectHome = true;
        CapabilityBoundingSet = "";
      };

      script =
        let
          args = lib.concatStringsSep " " (
            [
              "--address ${icfg.address}"
              "--port ${toString icfg.port}"
            ]
            ++ lib.optional icfg.debug "--debug"
            ++ lib.optional icfg.verbose "--verbose"
            ++ lib.optional icfg.json "--json"
          );
        in
        if icfg.passwordFile != null then
          ''
            export GS1200_PASSWORD=$(cat ${icfg.passwordFile})
            exec ${lib.getExe pkgs.gs1200-exporter} ${args}
          ''
        else
          ''
            export GS1200_PASSWORD=${lib.escapeShellArg icfg.password}
            exec ${lib.getExe pkgs.gs1200-exporter} ${args}
          '';
    };
  };

in
{
  options.services.gs1200-exporter = {
    instances = lib.mkOption {
      type = lib.types.attrsOf (lib.types.submodule instanceOpts);
      default = { };
      description = ''
        Each attribute defines a separate gs1200-exporter instance for one switch.
        Use this to monitor multiple GS1200 switches on the same host.
      '';
      example = lib.literalExpression ''
        {
          switch-1 = {
            address = "192.168.1.3";
            port = 9934;
            passwordFile = "/run/secrets/gs1200-password";
          };
          switch-2 = {
            address = "192.168.1.4";
            port = 9935;
            passwordFile = "/run/secrets/gs1200-password";
          };
        }
      '';
    };
  };

  config = lib.mkIf (cfg.instances != { }) {
    assertions = lib.flatten (
      lib.mapAttrsToList (name: icfg: [
        {
          assertion = icfg.address != "";
          message = "services.gs1200-exporter.instances.${name}: address must be set.";
        }
        {
          assertion = (icfg.password == null) != (icfg.passwordFile == null);
          message = "services.gs1200-exporter.instances.${name}: exactly one of password or passwordFile must be set.";
        }
      ]) cfg.instances
    );

    users.users = lib.mapAttrs' (
      name: icfg:
      lib.nameValuePair icfg.user {
        isSystemUser = true;
        inherit (icfg) group;
        description = "gs1200-exporter '${name}' service user";
      }
    ) cfg.instances;

    users.groups = lib.mapAttrs' (_name: icfg: lib.nameValuePair icfg.group { }) cfg.instances;

    systemd.services = lib.mkMerge (lib.mapAttrsToList mkService cfg.instances);
  };
}
