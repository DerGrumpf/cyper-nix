{ pkgs, oidcwarden-src, ... }:

pkgs.vaultwarden.overrideAttrs (old: {
  pname = "oidcwarden";
  src = oidcwarden-src;
  cargoDeps = pkgs.rustPlatform.importCargoLock {
    lockFile = "${oidcwarden-src}/Cargo.lock";
  };
  postInstall = (old.postInstall or "") + ''
    mv $out/bin/oidcwarden $out/bin/vaultwarden
  '';
})
