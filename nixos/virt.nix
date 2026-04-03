{ pkgs, ... }:
{
  virtualisation.libvirtd.enable = true;
  boot.binfmt.emulatedSystems = [
    "aarch64-linux"
    "riscv64-linux"
  ];
  environment.systemPackages = with pkgs; [
    qemu
    quickemu
    quickgui
    nemu
  ];
  systemd.tmpfiles.rules = [
    "L+ /var/lib/qemu/firmware - - - - ${pkgs.qemu}/share/qemu/firmware"
  ];
  environment.etc."qemu/bridge.conf".text = ''
    allow br0
  '';
}
