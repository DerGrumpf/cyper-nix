{
  lib,
  stdenv,
  fetchFromGitLab,
  makeWrapper,
  runCommand,
  makeDesktopItem,
  copyDesktopItems,
  gmqcc,
  libjpeg,
  zlib,
  libvorbis,
  curl,
  freetype,
  libpng,
  libtheora,
  libx11,
  SDL2,
  gmp,
  autoconf,
  automake,
  libtool,
  withSDL ? true,
  withDedicated ? true,
}:

let
  version = "0-unstable-2025-01-01";
  target = "release";

  darkplaces-src = fetchFromGitLab {
    domain = "gitlab.com";
    owner = "xonotic";
    repo = "darkplaces";
    rev = "ddabe55ae766087df0b82d214ca4b6d79a443345";
    hash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
  };

  d0_blind_id-src = fetchFromGitLab {
    domain = "gitlab.com";
    owner = "xonotic";
    repo = "d0_blind_id";
    rev = "64983f4156e860a94a6f5e264c67a1c2df69d7e9";
    hash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
  };

  xonotic-data = fetchFromGitLab {
    domain = "gitlab.com";
    owner = "xonotic";
    repo = "xonotic-data.pk3dir";
    rev = "bc2ce0925b46ff79d4deb4cf4995f1330f00de43";
    hash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
  };

  desktopItem = makeDesktopItem {
    name = "xonotic-latest";
    exec = "xonotic-latest";
    comment = "Free fast-paced first-person shooter (git build)";
    desktopName = "Xonotic (latest)";
    categories = [
      "Game"
      "Shooter"
    ];
    icon = "xonotic";
    startupNotify = false;
  };

  d0_blind_id-built = stdenv.mkDerivation {
    pname = "d0_blind_id";
    inherit version;
    src = d0_blind_id-src;

    nativeBuildInputs = [
      autoconf
      automake
      libtool
    ];
    buildInputs = [ gmp ];

    preConfigure = "autoreconf -fi";
    configureFlags = [ "--prefix=$out" ];
    enableParallelBuilding = true;
  };

  darkplaces-built = stdenv.mkDerivation {
    pname = "darkplaces-xonotic-latest";
    inherit version;
    src = darkplaces-src;

    buildInputs = [
      libjpeg
      zlib
      libvorbis
      curl
      gmp
      libx11
      SDL2
    ];

    dontStrip = false;
    enableParallelBuilding = true;

    preBuild = ''
      mkdir -p ../d0_blind_id/include ../d0_blind_id/lib
      cp -r ${d0_blind_id-src}/*.h ../d0_blind_id/include/ 2>/dev/null || true
      ln -sf ${d0_blind_id-built}/lib/libd0_blind_id.a ../d0_blind_id/lib/
      ln -sf ${d0_blind_id-built}/lib/libd0_rijndael.a ../d0_blind_id/lib/ 2>/dev/null || true
    '';

    buildPhase = ''
      runHook preBuild
      ${lib.optionalString withDedicated ''
        make -j $NIX_BUILD_CORES sv-${target}
      ''}
      ${lib.optionalString withSDL ''
        make -j $NIX_BUILD_CORES sdl-${target}
      ''}
      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall
      mkdir -p $out/bin

      ${lib.optionalString withDedicated ''
        install -Dm755 darkplaces-dedicated $out/bin/xonotic-latest-dedicated
      ''}
      ${lib.optionalString withSDL ''
        install -Dm755 darkplaces-sdl $out/bin/xonotic-latest-sdl
      ''}

      ${lib.optionalString withDedicated ''
        patchelf --add-needed ${curl.out}/lib/libcurl.so $out/bin/xonotic-latest-dedicated
      ''}
      ${lib.optionalString withSDL ''
        patchelf \
          --add-needed ${curl.out}/lib/libcurl.so \
          --add-needed ${libvorbis}/lib/libvorbisfile.so \
          --add-needed ${libvorbis}/lib/libvorbisenc.so \
          --add-needed ${libvorbis}/lib/libvorbis.so \
          --add-needed ${freetype}/lib/libfreetype.so \
          --add-needed ${libpng}/lib/libpng.so \
          --add-needed ${libtheora}/lib/libtheora.so \
          $out/bin/xonotic-latest-sdl
      ''}
      runHook postInstall
    '';

    dontPatchELF = true;
  };

  xonotic-data-compiled = stdenv.mkDerivation {
    pname = "xonotic-latest-data";
    inherit version;
    src = xonotic-data;

    nativeBuildInputs = [ gmqcc ];

    buildPhase = ''
      runHook preBuild
      export QCC="${gmqcc}/bin/gmqcc"
      export QCCFLAGS_WATERMARK=nix_build
      export ZIP=/bin/true
      make -C qcsrc -j $NIX_BUILD_CORES
      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall
      mkdir -p $out
      cp -r . $out/xonotic-data.pk3dir
      runHook postInstall
    '';
  };

in
runCommand "xonotic-latest-${version}"
  {
    inherit version;
    nativeBuildInputs = [
      makeWrapper
      copyDesktopItems
    ];
    desktopItems = [ desktopItem ];

    meta = {
      description = "Free fast-paced first-person shooter (git build)";
      homepage = "https://xonotic.org/";
      license = lib.licenses.gpl2Plus;
      maintainers = with lib.maintainers; [ DerGrumpf ];
      platforms = lib.platforms.linux;
    };
  }
  ''
    mkdir -p $out/bin $out/share

    ${lib.optionalString withDedicated ''
      ln -s ${darkplaces-built}/bin/xonotic-latest-dedicated $out/bin/
    ''}
    ${lib.optionalString withSDL ''
      ln -s ${darkplaces-built}/bin/xonotic-latest-sdl $out/bin/
      ln -sf $out/bin/xonotic-latest-sdl $out/bin/xonotic-latest
    ''}

    copyDesktopItems

    for binary in $out/bin/xonotic-latest*; do
      wrapProgram "$binary" \
        --add-flags "-basedir ${xonotic-data-compiled}" \
        --prefix LD_LIBRARY_PATH : "${darkplaces-built}/lib"
    done
  ''
