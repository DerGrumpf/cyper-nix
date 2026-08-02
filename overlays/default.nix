{ nur }:
final: prev:
(nur.overlays.default final prev)
// {
  netradiant-custom = final.callPackage ./netradiant-custom.nix { };

  pythonPackagesExtensions = prev.pythonPackagesExtensions ++ [
    (pyFinal: pyPrev: {
      python-lsp-server = pyPrev.python-lsp-server.overridePythonAttrs (_: {
        doCheck = false;
      });
    })
  ];
}
