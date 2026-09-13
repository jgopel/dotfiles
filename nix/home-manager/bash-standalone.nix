{ lib, ... }:

{
  # A standalone Home Manager installation cannot set the account's login
  # shell, so hand interactive Bash sessions off to Fish.
  programs.bash.initExtra = lib.mkAfter ''
    if [[ $- == *i* && -z "$BASH_EXECUTION_STRING" ]]; then
      exec fish
    fi
  '';
}
