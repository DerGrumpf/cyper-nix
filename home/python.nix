{ pkgs, ... }:
{
  home.packages = with pkgs; [
    python314
    python314Packages.pip
    python314Packages.virtualenv

    (python314Packages.pipx.overridePythonAttrs (_: {
      doCheck = false;
    }))
    uv
  ];

  home.sessionVariables = {
    PYTHON = "${pkgs.python313}/bin/python3";
  };

  programs.fish.shellAliases = {
    venv = "python3 -m venv";
    activate = "source venv/bin/activate.fish";
  };
}
