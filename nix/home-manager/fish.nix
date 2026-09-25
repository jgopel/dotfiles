{ pkgs, ... }:

{
  home.packages = with pkgs.fishPlugins; [
    done
    fzf-fish
  ];

  xdg.configFile."fish/completions/bazel.fish".source =
    "${pkgs.bazel_9}/share/fish/vendor_completions.d/bazel.fish";

  xdg.configFile."fish/completions/devenv.fish".source =
    "${pkgs.devenv}/share/fish/vendor_completions.d/devenv.fish";

  programs.fish = {
    enable = true;

    plugins = [
      {
        name = "loadenv";
        src = pkgs.fetchFromGitHub {
          owner = "berk-karaal";
          repo = "loadenv.fish";
          rev = "v1.1.0";
          sha256 = "sha256-+DmAnmHXHYlHjH95eMjPx2RBvt3BK5uNp+OjnM3QXO0=";
        };
      }
    ];

    shellAliases = {
      ls = "ls -F --ignore-backups --color --group-directories-first --human-readable";
      ll = "ls -l";
      la = "LC_COLLATE=C ls -A";
      lla = "la -l";
      gdb = "gdb -silent";
      refresh = "source ~/.config/fish/config.fish";
      tmux = "tmux -u";
      sudol = "sudo -E";
    };

    shellInit = ''
      # Disable greeting
      set -g fish_greeting

      # vim mode
      fish_vi_key_bindings
    '';

    interactiveShellInit = ''
      # Add ~/bin to PATH
      fish_add_path -g $HOME/bin

      # et (eternal-terminal) completions - wraps ssh for host/user completions
      complete -c et --wraps ssh

      # Bazelisk uses Bazel's completions
      complete -c bazelisk --wraps bazel

      # Environment settings
      set -gx VISUAL nvim
      set -gx EDITOR nvim
      set -gx TZ 'America/Denver'

      # Python cache directory
      set -gx PYTHONPYCACHEPREFIX "$HOME/.cache/cpython/"

      # Continuation prompt
      set -g fish_prompt_pwd_dir_length 0
    '';

    functions = {
      ct = ''
        command cargo test --color always $argv -- --color always 2>&1 | sed 's/\//g' | less -RFX
      '';
    };
  };
}
