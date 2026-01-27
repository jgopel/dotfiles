{ pkgs, ... }:

{
  # Add mosh-server to PATH so SSH can spawn it
  home.sessionPath = [ "${pkgs.mosh}/bin" ];
}
