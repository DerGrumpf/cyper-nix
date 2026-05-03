{ lib, pkgs, ... }:
let
  octoprint-overlay = self: super: {
    octoprint = super.octoprint.override {
      packageOverrides = pyself: pysuper: {

        octoprint-customcss = pyself.buildPythonPackage {
          pname = "OctoPrint-CustomCSS";
          version = "20201210";
          format = "setuptools";
          src = pkgs.fetchFromGitHub {
            owner = "crankeye";
            repo = "OctoPrint-CustomCSS";
            rev = "7a042b11055592b42b59298ad8d579b731081acd";
            sha256 = "sha256-N5DjaZ2KzSi1xfmvhS8gWKAMyXz5btYqU1QSRIMkFZY=";
          };
          propagatedBuildInputs = [ pysuper.octoprint ];
          doCheck = false;
          meta = with lib; {
            description = "A simple plugin for adding custom CSS to OctoPrint";
            homepage = "https://github.com/crankeye/OctoPrint-CustomCSS";
            license = licenses.agpl3Only;
          };
        };

        octoprint-bedlevelvisualizer = pyself.buildPythonPackage {
          pname = "OctoPrint-BedLevelVisualizer";
          version = "1.1.1";
          format = "setuptools";
          src = pkgs.fetchFromGitHub {
            owner = "jneilliii";
            repo = "OctoPrint-BedLevelVisualizer";
            rev = "1.1.1";
            sha256 = "1v7gqyp605z3hyc1w8a2h6ir6k0vp2ccby1wwxlri6h4i2yii5z8";
          };
          propagatedBuildInputs = [ pysuper.octoprint ];
          doCheck = false;
          meta = with lib; {
            description = "Visualize your bed leveling via a 3D mesh";
            homepage = "https://github.com/jneilliii/OctoPrint-BedLevelVisualizer";
            license = licenses.mit;
          };
        };

      };
    };
  };
in
{
  nixpkgs.overlays = [ octoprint-overlay ];
  services.octoprint = {
    enable = true;
    host = "0.0.0.0";
    openFirewall = true;
    port = 5000;
    plugins =
      ps: with ps; [
        octoprint-customcss
        octoprint-bedlevelvisualizer
      ];
  };
}
