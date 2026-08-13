{ config, ... }:

let
  secretsDir = "${config.xdg.dataHome}/rclone";
in
{
  programs.rclone = {
    enable = true;

    remotes.gdrive = {
      config = {
        type = "drive";
        scope = "drive";
      };
      secrets = {
        client_id = "${secretsDir}/google-drive-client-id";
        client_secret = "${secretsDir}/google-drive-client-secret";
        token = "${secretsDir}/google-drive-token.json";
      };

      mounts."" = {
        enable = true;
        mountPoint = "${config.home.homeDirectory}/google-drive";
      };
    };
  };
}
