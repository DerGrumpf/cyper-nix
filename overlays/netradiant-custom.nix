{
  lib,
  stdenv,
  fetchFromGitHub,
  fetchgit,
  pkg-config,
  makeWrapper,
  subversion,
  git,
  unzip,
  wget,
  qt5,
  glib,
  libxml2,
  zlib,
  libpng,
  assimp,
}:
let
  xonoticPack = fetchgit {
    url = "https://gitlab.com/xonotic/netradiant-xonoticpack.git";
    rev = "b9b95499e6bd1082a4eaff78664f9243cbcbb2e1";
    hash = "sha256-boSWipgiQzXHFJ0KGpd8xbwik3hKQK3IKSNByUaUHBk=";
  };
in
stdenv.mkDerivation rec {
  pname = "netradiant-custom";
  version = "20260114";
  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "Garux";
    repo = "netradiant-custom";
    rev = version;
    hash = "sha256-dlJn10Y45mx3UwxvB8mzw5Ok8LvvxVpMwDAdHXSt5dk=";
  };

  nativeBuildInputs = [
    pkg-config
    makeWrapper
    subversion
    git
    unzip
    wget
  ];

  buildInputs = [
    qt5.qtbase
    qt5.qtsvg
    glib
    libxml2
    zlib
    libpng
    assimp
  ];

  makeFlags = [
    "DOWNLOAD_GAMEPACKS=no"
    "DEPENDENCIES_CHECK=off"
    "BUILD=release"
  ];

  enableParallelBuilding = true;

  dontWrapQtApps = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/opt/netradiant-custom
    cp -r install/* $out/opt/netradiant-custom/

    # Replicates what upstream's install-gamepack.sh does:
    # - files in <pack>/games/*.game go into gamepacks/games/
    # - directories named <pack>/*.game go into gamepacks/ directly
    mkdir -p $out/opt/netradiant-custom/gamepacks/games
    if [ -d "${xonoticPack}/games" ]; then
      cp -r ${xonoticPack}/games/*.game $out/opt/netradiant-custom/gamepacks/games/
    fi
    for d in ${xonoticPack}/*.game; do
      cp -r "$d" $out/opt/netradiant-custom/gamepacks/
    done

    mkdir -p $out/bin
    makeWrapper $out/opt/netradiant-custom/radiant.x86_64 $out/bin/netradiant-custom \
      --chdir "$out/opt/netradiant-custom" \
      --prefix QT_PLUGIN_PATH : "${qt5.qtbase}/${qt5.qtbase.qtPluginPrefix}" \
      --set QT_QPA_PLATFORM xcb

    runHook postInstall
  '';

  meta = {
    description = "Cross-platform level editor for id Tech based games (NetRadiant fork)";
    homepage = "https://github.com/Garux/netradiant-custom";
    license = lib.licenses.gpl2Plus;
    mainProgram = "netradiant-custom";
    platforms = lib.platforms.linux;
  };
}
