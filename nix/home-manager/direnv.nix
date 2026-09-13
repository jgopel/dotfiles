{
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
    config.global.log_format = builtins.fromJSON ''"\u001b[2mdirenv: %s\u001b[0m"'';
  };
}
