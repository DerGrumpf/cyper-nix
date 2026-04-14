{ ... }:
{
  services.filebrowser = {
    enable = true;

    settings = {
      port = 10000;
      address = "0.0.0.0";
      baseURL = "/filebrowser";
      root = "/storage";
    };

    openFirewall = true;
  };

}
