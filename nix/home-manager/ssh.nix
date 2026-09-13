{ pkgs, ... }:

{
  home.packages = [ pkgs.openssh_gssapi ];

  services.ssh-agent.enable = true;
}
