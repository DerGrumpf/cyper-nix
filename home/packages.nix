{
  pkgs,
  lib,
  isServer,
  ...
}:
{
  home = {
    packages =
      with pkgs;
      [
        # dev tools
        curl
        wget
        btop
        tree
        ripgrep
        jq
        yq-go
        # GUI
        openscad
        fstl
        # PDF Tools
        pandoc
        # misc
        yt-dlp
        ffmpeg
        # Archives
        zip
        unzip
        xz
        zstd
        gnutar
        unrar
        sops
        age
        # Nix tools
        nix-index
        ncdu
        tty-solitaire
      ]
      ++ lib.optionals (!pkgs.stdenv.isDarwin) [
        # dev tools
        pciutils
        usbutils
        nvme-cli
        nmap
        iperf3
        lm_sensors
        file
        which
        libnotify
        # encryption
        ssh-to-age
      ]
      ++ lib.optionals (!pkgs.stdenv.isDarwin && !isServer) [
        # GUI
        element-desktop
        zapzap
        nautilus
        swayimg
        kdePackages.okular
        gnumeric
        sqlitebrowser
        thunderbird
        xonotic
        irssi
        blender
      ]
      ++ lib.optionals pkgs.stdenv.isDarwin [ graphite-cli ];
  };
}
