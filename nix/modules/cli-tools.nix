{
  den.aspects.cli-tools.homeManager = { pkgs, ... }: {
    home.packages = with pkgs; [
      bash
      curl
      dtrx
      inetutils
      jq
      just
      less
      plocate
      ripgrep
      rsync
      time
      tree
      unzip
      wget
      yq
    ];
  };
}
