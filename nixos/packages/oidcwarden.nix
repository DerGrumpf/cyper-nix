{
  pkgs,
  fetchFromGitHub,
  ...
}:
let
  src = fetchFromGitHub {
    owner = "Timshel";
    repo = "OIDCWarden";
    rev = "48edfc7ba54372074befa1d62c63c4babfaadc77";
    hash = "sha256-tHacn9RtoByWpqnWX2/gWwODDSeXJa4mk4MfxHiiJ8A=";
  };
in
pkgs.vaultwarden.overrideAttrs (old: {
  pname = "oidcwarden";
  inherit src;
  cargoDeps = pkgs.rustPlatform.importCargoLock {
    lockFile = "${src}/Cargo.lock";
  };
  postInstall = (old.postInstall or "") + ''
    mv $out/bin/oidcwarden $out/bin/vaultwarden
  '';
})
