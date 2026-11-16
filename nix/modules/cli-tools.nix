{
  den.aspects.cli-tools = {
    homeManager = { pkgs, ... }: {
      home.packages = with pkgs; [
        bash
        curl
        dtrx
        inetutils
        jq
        just
        less
        ripgrep
        rsync
        time
        tree
        unzip
        wget
        yq
      ];
    };

    hmLinux = { pkgs, ... }: { home.packages = [ pkgs.plocate ]; };
    hmDarwin = { pkgs, ... }: { home.packages = [ pkgs.coreutils ]; };
  };
}
