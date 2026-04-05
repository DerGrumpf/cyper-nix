{ pkgs, lib, ... }: {
  home = {
    packages = with pkgs;
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

        # Nix tools
        nix-index
      ] ++ lib.optionals (!pkgs.stdenv.isDarwin) [
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
        age
        ssh-to-age

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
      ] ++ lib.optionals pkgs.stdenv.isDarwin [ graphite-cli ];
  };
}
