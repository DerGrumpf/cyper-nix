{
  vaultwarden,
  rustPlatform,
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
vaultwarden.overrideAttrs (old: {
  pname = "oidcwarden";
  inherit src;
  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit src;
    hash = "sha256-eGsYNaLYRCrTRaoyfhxnoeA2ytYeyGGvHnAbpEIayzs=";
  };
  postInstall = (old.postInstall or "") + ''
    mv $out/bin/oidcwarden $out/bin/vaultwarden
  '';
})
