{ repoRoot, ... }:

{
  den.aspects.tmux.homeManager =
    { lib, pkgs, ... }:

    let
      cpuPercentage = pkgs.writeShellApplication {
        name = "tmux-cpu-percentage";
        runtimeInputs = [
          pkgs.sysstat
          pkgs.gawk
        ];
        text = ''
          # Sample one second, excluding both idle and I/O wait (as btop does).
          LC_ALL=C iostat -y -c 1 1 | awk '
            NF == 6 && $1 ~ /^[0-9]/ { printf "%.1f%%", 100 - $4 - $6 }
          '
        '';
      };
    in
    {
      home.packages = [ pkgs.tmux ];
      home.sessionVariables = lib.mkIf pkgs.stdenv.hostPlatform.isLinux {
        TMUX_TMPDIR = "\${XDG_RUNTIME_DIR:-\"/run/user/$(id -u)\"}";
      };

      xdg.configFile."tmux/tmux.conf".text =
        lib.replaceStrings
          [ "@sensible@" "@cpu@" "@cpu-percentage@" ]
          [
            "${pkgs.tmuxPlugins.sensible.rtp}"
            "${pkgs.tmuxPlugins.cpu.rtp}"
            "${cpuPercentage}/bin/tmux-cpu-percentage"
          ]
          (builtins.readFile (repoRoot + /tmux/tmux.conf));
    };
}
