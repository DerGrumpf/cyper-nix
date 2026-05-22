final: prev: {
  gs1200-exporter = final.callPackage ./gs1200-exporter.nix { };
  oidcwarden = final.callPackage ./oidcwarden.nix { inherit (prev) vaultwarden; };
}
