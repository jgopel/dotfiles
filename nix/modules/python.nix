{
  den.aspects.python.homeManager = { pkgs, ... }: {
    home.packages = with pkgs; [
      isort
      python3
      ruff
      ty
      uv
    ];

    programs.fish.interactiveShellInit = ''
      # Python cache directory
      set -gx PYTHONPYCACHEPREFIX "$HOME/.cache/cpython/"
    '';
  };
}
