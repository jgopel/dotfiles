{ config, pkgs, ... }:

{
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
      grep = "grep --color=auto";
      gdb = "gdb -silent";
      cscope = "cscope -qR";
      refresh = "source ~/.config/fish/config.fish";
      tmux = "tmux -u";
      sudol = "sudo -E";
      pr = "poetry run";
      link-lvimrc = "ln -s ~/dotfiles/vim/default-lvimrc .lvimrc";

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

      # Environment settings
      set -gx SVN_EDITOR nvim
      set -gx VISUAL nvim
      set -gx EDITOR nvim
      set -gx CSCOPE_EDITOR nvim
      set -gx TZ 'America/Denver'

      # Python cache directory
      set -gx PYTHONPYCACHEPREFIX "$HOME/.cache/cpython/"

      # API Keys
      set -gx GEMINI_API_KEY "<redacted>"

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
