{ primaryUser, ... }:
{
  services.openssh = {
    enable = true;
    openFirewall = true;
    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "no";
    };
  };
  users.users.${primaryUser}.openssh.authorizedKeys.keyFiles = [ ../secrets/ssh-key ];
  programs.ssh = {
    startAgent = true;
    knownHosts = {
      "git-cyperpunk" = {
        hostNames = [ "[git.cyperpunk.de]:12222" ];
        publicKey = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCgGpu6/BTsm6l4oIGD8kHz1TxJr7h3U9iuXnUCE2arTj5RnMXmy+fRdbEhlwUv1sfhhyC0HfWImK/z+PtJTGGXAE1NWMUj23k3ysw5E1n//whu9rHDZXV6MII/2xNPM5dapzhU0Kwemu86429zD/YyWqWwuMfCrudYXgrQIihWK3QbyeKORtKwo2Ae3ItHmMygP1WTnIoRHZuIIBiMKN3YMvdoBMpz8aLW74uGNWlGTFWDECG4VdYcrRe0cL2wM/a/2U97rkbXx50aNkq82uaXHQ3bR3Ze1lp1a869uPNRJwV7keMd+KgJUW0+uN8HE9cbe0tVDAmEcABGgCm80clxRzmLOpyU/zXWgv/d2jGauQDkZuSwTlsOIb1CLRIwERB7ld0qixoH70dWBv8dE7hHb5YsCN+/P4hbZ7TzDIcBQC8hPJwc5WKNhdNmkTVkQog2dXx9Yt4g4Ro2ufjehavwkxVzSsTbulVOR6YbCk1Cjd6G4yOrfFG1210fePjACHkFkJXQEX+Dk4fKJnc/fylbBQtFDpbPXxw0hYoViMAjOCAszFP51Vs33Kebn+vM3wNzI7IMH4JuyBbP7nzVuSFfY4QlR/0LO6NzwJ8ShlLsajNYmTKl7eMC7eCh9Sl5WHDFeQX4BkN0o/xonDUyGOyWc2noThQU8t9HgKZ7jbuhdQ==";
      };

      "proxy-ed25519" = {
        hostNames = [
          "proxy.cyperpunk.de"
          "10.10.0.1"
          "195.90.219.9"
        ];
        publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBXsVoqYcVX+afj4fWAMyoYpP4yW4ubHovebdrX00Swc";
      };

      "proxy-rsa" = {
        hostNames = [
          "proxy.cyperpunk.de"
          "10.10.0.1"
          "195.90.219.9"
        ];
        publicKey = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC7GHp/cgPEsMEVu56zDrol1YYbDvPN/3cB7HPA/ENp2qP8foRrgJHPEjFgfEX6tEbnKwXXSxaa7DckSYcwkTbn8DLmJ2bpMDxl4UKwF+9wbu9QCTMBagqnXlGq18qbfTDokZi92RRiGQvrOHGByCVAuAsBMuvmWiGztn7FiDz7Rq0udY/lonOtCiwn2qIFaywkf61RXqxX5MEzRWKergOSlvcv2z9cxyeLxWnigeYdpnh4vIRxjReeXIbaSIJgD9XVM26h1uj239S+7iMe3Lo/qCKrvrXYzjcn42bp5jZaFoTMfPWJkucReWUqiKNGLL/gzzbbeVGtFiHmfNDIt3W7uttw264DcZJ85gia32p5DsX2gmjZdQ74clzkauvrubHC5yGQr+6ZraZ0wmJIUT4yaeb97GAHIwff1zPM+C6ASi6YLVIA7meLwzY2ywaUnOQBIHaUYXLUx2snzGAj8hxfhgqtbo4pmhxEmpxDml5mvSj8oQwjR+eRhgrHUX5xCH+GBNAuwlApDnVojeqlXfmYZOS7xdeuw+onXkkHVG9hH2QcViqcmRL+Bda9Bh2EAO69tncqEa6456FPqapzLQHViUU/7kr6NfMEgxOFrkAQW0qiql4tRKLpOQapEFIrJwJwE5e8ZTNDO2ZB24XHhpOywGcU4NLrVL+LJ7NdukoWLw==";
      };

      "desktop-ed25519" = {
        hostNames = [
          "desktop.cyperpunk.de"
          "10.10.0.40"
          "192.168.2.40"
        ];
        publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINpb12F+i3QLApcTtJ2/fcT7WFjo/ZC7AyqnW5sSlB6x";
      };

      "desktop-rsa" = {
        hostNames = [
          "desktop.cyperpunk.de"
          "10.10.0.40"
          "192.168.2.40"
        ];
        publicKey = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDCntVNG94P6fVpk49HnNqBlk0BbWIb3fmFh9Xvu2ifngOJof7fYO0N68Bu2ehE+shDA4tmfFCHercx+OK64JpmbY6fKfWKOQ6fRXH0Ty58qWdmXVZ26REOmTA4Ygz17YbtyyyKNSsWLMPMXx7g0eMG7TDihg6ROAm1kVOM8qIk8a7dS2mTB/riyFwP+EPCOh5IQiKGY5q3EoOLKBp6nM/jVDURidZ8C833xrG15MgUy1KlJ7sFenpmDN5maTtV+P1rEgFn4YlPO9Rbi3aqr520VlcjEsoWFF0QofQ+IxtIID2VuQX34+GN126Cs0h2Fy+N1DfJLzYdHnEGdVoU9wos3z49pPQD0WpCdF2VNc2TwSUpE7KfEJDpnFzWKjRauOT3zzZmladZl11CldkXaPSPZZI7s+3ermJcEdbfrAcZ89aNiEKmS9bac4g2JGaC8vkjPabkOs35wG2JBEjTvf0IVi7jw+WRKxnn2KtVjxg2VjaXwHuzn6ivw0VMy2m3w7NiVrvjOr2hOjuRAXtInpX8yRxtz3Im0q2raGAmINB3IcvUnMAZRfmCrJ/PfcGkx1fTppnp/deAt9GIjWsW1wvkMVdJ46Mrlyyd4yG8nvGlBAhVv13+lzA1hykQf55ANkhwA1OjOgJwqmGjzf9HhZHHNTLWXocKyz3SPnInveXOGQ==";
      };

      "controller-ed25519" = {
        hostNames = [
          "controller.cyperpunk.de"
          "10.10.0.2"
          "192.168.2.2"
        ];
        publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJK4kXvNiLVeLaM9wbel559BBZ+T4YhSpfZ3cWtXilOr";
      };

      "controller-rsa" = {
        hostNames = [
          "controller.cyperpunk.de"
          "10.10.0.2"
          "192.168.2.2"
        ];
        publicKey = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC6awRInNcUt6tLi0/0aoCggXAI+tdGPjn/fJ0J8J7OhqJgQ1gSE1M/swMfs+9XOeXp6+ZHzn2F9wfFhlNZcWdOqlUsvXM4SX6qtlG3ILSnYJyFdvUQ/7ItlFovYrPLDLMsVqcsV6XHzq2KxWGNb34W7opI7Idg67tSs16f6x9sKJD0+VHheB0paW2IgVPUqAe8cZSirtqe5xsFRH/pkAcTSnGvoVICgV26du+arvfRxOC1PLEeaXlDhEsnyeOfmE2ssc103rxHVCGh+kdrV+hrl6WVVEh4qajSNxhHmNQ44M6aU1EQSSTGcwWT4oYCPsw1EBhIDTaVMBMc8TElvGIhQwtXM6l9CjDLsihtNhaJ3HrII3yuHPVgR4HopQDrimfsemoExkmp71InKG/oCOAqCvKB03/xsCwg9EfXkCyCiK9kz9G3izFyul7Jk0MEQPdmL1ts3rgjyTQL2tMmsGyRyHXridgrP7+EaF2orhT1GS5rGSULXHbYS9b4NNguHzwcKBiRdHZx9kT76BlcygZsS4Q4W1RR9K+ZhalgO9+Qxu4CGbMDtMi5BpuXTVulLwXM7nKr8pZN/NvjHPbQtorUft2wEB8O0dVzURgJCxCTOERGS/aHrXmGih8sYgJsUQFyMKhtjSMHTr1Ag30PmOVQ4o24gv5BDvdNfEcO3gYSwQ==";
      };
    };
  };
  security = {
    sudo = {
      enable = true;
      wheelNeedsPassword = false;
    };
    doas = {
      enable = true;
      wheelNeedsPassword = false;
    };
  };
}
