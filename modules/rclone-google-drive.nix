{ config, ... }:

let
  tokenFile = "${config.xdg.dataHome}/rclone/google-drive-token.json";
in
{
  programs.rclone = {
    enable = true;

    remotes.gdrive = {
      config = {
        type = "drive";
        scope = "drive";
      };
      secrets.token = tokenFile;

      mounts."" = {
        enable = true;
        mountPoint = "${config.home.homeDirectory}/google-drive";
      };
    };
  };
}
