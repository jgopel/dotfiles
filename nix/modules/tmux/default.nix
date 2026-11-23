{ lib, repoRoot, ... }:

let
  renderConfig =
    pkgs: cpuPercentage:
    lib.replaceStrings
      [ "@sensible@" "@cpu@" "@cpu-percentage@" ]
      [ "${pkgs.tmuxPlugins.sensible.rtp}" "${pkgs.tmuxPlugins.cpu.rtp}" cpuPercentage ]
      (builtins.readFile (repoRoot + /tmux/tmux.conf));
in
{
  den.aspects.tmux = {
    homeManager = { pkgs, ... }: {
      home.packages = [
        (pkgs.tmux.overrideAttrs (old: {
          # tmux 3.8 `select-layout -E` ignores split cells when spreading panes,
          # pushing a stacked column past the window edge. Backport upstream
          # 67d1c4dc (tmux/tmux#5776). Once a release includes it, this patch
          # no longer applies and the build fails: remove it then.
          patches = (old.patches or [ ]) ++ [ ./select-layout-spread-tiled-children.patch ];
        }))
      ];
    };

    hmLinux =
      { pkgs, ... }:
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
        home.sessionVariables.TMUX_TMPDIR = "\${XDG_RUNTIME_DIR:-\"/run/user/$(id -u)\"}";
        xdg.configFile."tmux/tmux.conf".text = renderConfig pkgs "${cpuPercentage}/bin/tmux-cpu-percentage";
      };

    hmDarwin = { pkgs, ... }: {
      home.sessionVariables.TMUX_TMPDIR = "$(/usr/bin/getconf DARWIN_USER_TEMP_DIR)";
      xdg.configFile."tmux/tmux.conf".text =
        renderConfig pkgs "${pkgs.tmuxPlugins.cpu.rtp}/scripts/cpu_percentage.sh";
    };
  };
}
