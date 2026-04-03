{ pkgs, ... }: {
  home.packages = with pkgs; [
    # Python 3.14 (newest stable)
    python314
    python314Packages.pip
    python314Packages.virtualenv

    # Additional useful tools
    python314Packages.pipx # Install Python apps in isolated environments
    uv # Fast Python package installer (alternative to pip)
  ];

  # Set up default Python version
  home.sessionVariables = { PYTHON = "${pkgs.python313}/bin/python3"; };

  programs.fish.shellAliases = {
    venv = "python3 -m venv";
    activate = "source venv/bin/activate.fish";
  };
}
