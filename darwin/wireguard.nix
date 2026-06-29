{
  config,
  pkgs,
  hostName,
  ...
}:
{
  sops.secrets."wireguard/${hostName}" = {
    mode = "0400";
  };

  launchd.daemons.wireguard = {
    script = ''
      set -e
      mkdir -p /etc/wireguard
      PRIVATE_KEY=$(cat ${config.sops.secrets."wireguard/${hostName}".path})
      cat > /etc/wireguard/wg0.conf << EOF
      [Interface]
      Address = $WG_IP
      PrivateKey = $PRIVATE_KEY

      [Peer]
      PublicKey = NjMYaUZO/iPRM/J46qyPPuWYg5oSeAUxjocMs/hYTXs=
      Endpoint = 178.254.8.35:51820
      AllowedIPs = 10.10.0.0/24
      PersistentKeepalive = 25
      EOF
      chmod 600 /etc/wireguard/wg0.conf
      ${pkgs.wireguard-tools}/bin/wg-quick up wg0
    '';
    environment.WG_IP = "";
    serviceConfig = {
      Label = "org.wireguard.wg0";
      RunAtLoad = true;
      KeepAlive = false;
      StandardOutPath = "/var/log/wireguard.log";
      StandardErrorPath = "/var/log/wireguard.log";
    };
  };
}
