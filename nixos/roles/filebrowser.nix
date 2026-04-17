{ ... }:
{
  services.filebrowser = {
    enable = true;

    settings = {
      port = 10000;
      address = "0.0.0.0";
      baseURL = "/filebrowser";
      root = "/storage";
      username = "DerGrumpf";
      password = "$2a$10$1LtSsdzJN4MqP7rjQhnQO.mL7nTuQBBCLbqSoFxL4XK1/I4b0sjdS";
    };

    openFirewall = true;
  };

}
