{
  config,
  ...
}:

let
  primaryInterface = config.systemd.network.networks."10-ethernet".matchConfig.Name;
  adguardPort = 3000;
in
{
  services = {
    resolved.enable = false;
    adguardhome = {
      enable = true;
      mutableSettings = true;
      allowDHCP = true;

      settings = {
        http.address = "0.0.0.0:${toString adguardPort}";

        users = [
          {
            name = "DerGrumpf";
            password = "$2a$10$EyuPHKxu0YZ9sXl4ZNMzRuvYCKWOeCobTkpXUJBhL14CCkWCY6FRm";
          }
        ];

        dns = {
          bind_hosts = [
            "0.0.0.0"
            "::"
          ];
          port = 53;
          upstream_dns = [
            "https://dns10.quad9.net/dns-query"
            "https://dns.adguard-dns.com/dns-query"
            "https://0ms.dev/dns-query"
            "https://dns.cloudflare.com/dns-query"
            "https://security.cloudflare-dns.com/dns-query"
          ];
          bootstrap_dns = [
            "9.9.9.10"
            "149.112.112.10"
          ];
          fallback_dns = [
            "1.1.1.1"
            "8.8.8.8"
          ];
          upstream_mode = "load_balance";
        };

        dhcp = {
          enabled = false;
          interface_name = primaryInterface;
          local_domain_name = "lan";
          dhcpv4 = {
            gateway_ip = "192.168.2.1";
            subnet_mask = "255.255.255.0";
            range_start = "192.168.2.150";
            range_end = "192.168.2.200";
            lease_duration = 86400;
            icmp_timeout_msec = 1000;
          };
          dhcpv6 = {
            range_start = "fdbb:959a:27ee::100";
            lease_duration = 86400;
            ra_slaac_only = false;
            ra_allow_slaac = false;
          };
        };

        filters = [
          # --- existing ---
          {
            enabled = true;
            url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_1.txt";
            name = "AdGuard DNS filter";
            id = 1;
          }
          {
            enabled = true;
            url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_2.txt";
            name = "AdAway Default Blocklist";
            id = 2;
          }

          # --- malware & phishing ---
          {
            enabled = true;
            url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_9.txt";
            name = "The Big List of Hacked Malware Web Sites";
            id = 3;
          }
          {
            enabled = true;
            url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_11.txt";
            name = "Malicious URL Blocklist (URLhaus)";
            id = 4;
          }

          # --- telemetry ---
          {
            enabled = true;
            url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_3.txt";
            name = "AWAvenue Ads Rule";
            id = 5;
          }
          {
            enabled = true;
            url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_54.txt";
            name = "HaGeZi's Windows/Office Tracker Blocklist";
            id = 6;
          }

          # --- Smart TV / IoT ---
          {
            enabled = true;
            url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_59.txt";
            name = "HaGeZi's Smart TV Blocklist";
            id = 7;
          }
        ];

        filtering = {
          filtering_enabled = true;
          protection_enabled = true;
          safe_search.enabled = false;
          parental_enabled = false;
          safebrowsing_enabled = false;
        };
      };
    };
  };

  networking.firewall = {
    allowedTCPPorts = [
      53 # DNS
      adguardPort
    ];
    allowedUDPPorts = [
      53 # DNS
      67 # DCHP
    ];
  };
}
