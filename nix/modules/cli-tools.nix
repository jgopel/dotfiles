{
  den.aspects.cli-tools.homeManager = { pkgs, ... }: {
    home.packages = with pkgs; [
      bash
      curl
      dtrx
      gdb
      inetutils
      jq
      less
      perf
      plocate
      ripgrep
      rsync
      strace
      time
      tree
      unzip
      wget
      yq
    ];
  };
}
