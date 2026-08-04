{ pkgs, ... }:
let
  upstream = "10.10.0.2";

  mkProxy = port: {
    forceSSL = true;
    enableACME = true;
    locations."/" = {
      proxyPass = "http://${upstream}:${toString port}";
    };
  };

  mkWsProxy =
    port:
    (mkProxy port)
    // {
      locations."/" = {
        proxyPass = "http://${upstream}:${toString port}";
        proxyWebsockets = true;
      };
    };

  mkHttpsProxy = port: {
    forceSSL = true;
    enableACME = true;
    locations."/" = {
      proxyPass = "https://${upstream}:${toString port}";
      extraConfig = "proxy_ssl_verify off;";
    };
  };
in
{
  environment.persistence."/persist".directories = [
    {
      directory = "/var/lib/acme";
      user = "acme";
      group = "acme";
      mode = "0750";
    }
  ];

  networking.firewall.allowedTCPPorts = [
    80
    443
    12222
  ];

  systemd.tmpfiles.rules = [
    "d /var/www/home.cyperpunk.de 0755 nginx nginx -"
  ];

  security.acme = {
    acceptTerms = true;
    defaults.email = "phil.keier@hotmail.com";
  };

  services.nginx = {
    enable = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;
    recommendedOptimisation = true;
    recommendedGzipSettings = true;

    additionalModules = [ pkgs.nginxModules.subsFilter ];

    # Git ssh
    streamConfig = ''
      server {
        listen 12222;
        proxy_pass ${upstream}:12222;
      }
    '';

    virtualHosts = {
      # controller services (proxied to upstream tailscale node)
      "git.cyperpunk.de" = (mkProxy 9000) // {
        extraConfig = ''
          client_max_body_size 8192m;
          proxy_read_timeout 600s;
          proxy_send_timeout 600s;
          proxy_request_buffering off;
          proxy_buffering off;
        '';
      };
      "search.cyperpunk.de" = mkProxy 11080;
      "file.cyperpunk.de" = mkProxy 10000;
      "ngx.cyperpunk.de" = mkWsProxy 28101;
      "vault.cyperpunk.de" = mkWsProxy 8222;
      "calvin.cyperpunk.de" = mkWsProxy 15006;
      "auth.cyperpunk.de" = mkHttpsProxy 8444;

      #"home.cyperpunk.de" = {
      #  forceSSL = true;
      #  enableACME = true;
      #  locations."/" = {
      #    root = "/var/www/home.cyperpunk.de";
      #    extraConfig = ''
      #      try_files $uri $uri/ =404;
      #    '';
      #  };
      #};

      "www.cyperpunk.de" = {
        forceSSL = true;
        enableACME = true;
        locations = {
          "/" = {
            proxyPass = "http://${upstream}:15005";
            proxyWebsockets = true;
          };
          "/grafana" = {
            proxyPass = "http://${upstream}:2342";
            proxyWebsockets = true;
            extraConfig = ''
              add_header X-Frame-Options "";
              add_header Content-Security-Policy "frame-ancestors *";
            '';
          };
          "/jupyter/" = {
            proxyPass = "http://${upstream}:8000/jupyter/";
            proxyWebsockets = true;
            extraConfig = ''
              proxy_set_header X-Scheme $scheme;
              proxy_buffering off;
              proxy_read_timeout 86400s;
            '';
          };
          "/hydra/" = {
            proxyPass = "http://${upstream}:3000/";
            proxyWebsockets = true;
            extraConfig = ''
              	proxy_set_header X-Forwarded-Proto $scheme;
              	proxy_set_header X-Forwarded-Host $host;
              	proxy_set_header X-Forwarded-Path /hydra;
              	proxy_set_header X-Request-Base "https://www.cyperpunk.de/hydra";
              	proxy_set_header Accept-Encoding "";
              	sub_filter_once off;
              	sub_filter_types text/html text/css application/javascript;
              	sub_filter 'http://www.cyperpunk.de/static' 'https://www.cyperpunk.de/hydra/static';
              	sub_filter 'http://www.cyperpunk.de/login' 'https://www.cyperpunk.de/hydra/login';
              	sub_filter ' href="/' ' href="/hydra/';
              	sub_filter ' src="/' ' src="/hydra/';
              	sub_filter ' action="/' ' action="/hydra/';
                sub_filter '</head>' '<link rel="stylesheet" href="https://www.cyperpunk.de/hydra-theme/mocha.css"></head>';
            '';
          };
          "= /hydra-theme/mocha.css" = {
            alias = "${./hydra-theme.css}";
            extraConfig = ''
              add_header Cache-Control "no-cache";
            '';
          };
        };
      };
    };
  };
}
