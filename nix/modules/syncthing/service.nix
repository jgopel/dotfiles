{
  config,
  pkgs,
  lib,
  ...
}:

with lib;

let
  cfg = config.services.syncthing-user;

  # Type for a sync folder configuration
  folderType = types.submodule {
    options = {
      path = mkOption {
        type = types.str;
        description = "Path to the folder to sync";
      };
      stignore = mkOption {
        type = types.path;
        description = "Path to .stignore file to install in this folder";
      };
    };
  };

  # Type for SSH tunnel configuration
  tunnelType = types.submodule {
    options = {
      name = mkOption {
        type = types.str;
        description = "Name for this tunnel (used in service name)";
      };
      host = mkOption {
        type = types.str;
        description = "SSH host (user@hostname or hostname)";
      };
      localPort = mkOption {
        type = types.port;
        description = "Local port to forward to remote syncthing GUI";
      };
      remotePort = mkOption {
        type = types.port;
        default = 8384;
        description = "Remote syncthing GUI port";
      };
    };
  };
in
{
  options.services.syncthing-user = {
    enable = mkEnableOption "Syncthing file synchronization";

    clusters = mkOption {
      type = types.listOf types.str;
      default = [ ];
      description = ''
        List of cluster names this machine belongs to.
        Used for documentation/organization purposes.
        Examples: [ "nascent" "personal" ]
      '';
    };

    guiAddress = mkOption {
      type = types.str;
      default = "127.0.0.1:8384";
      description = "Address for the Syncthing web GUI";
    };

    folders = mkOption {
      type = types.listOf folderType;
      default = [ ];
      description = "List of folders to sync";
      example = literalExpression ''
        [
          { path = "~/work"; stignore = ./syncthing/stignore-work; }
        ]
      '';
    };

    tunnels = mkOption {
      type = types.listOf tunnelType;
      default = [ ];
      description = "SSH tunnels to remote syncthing GUIs";
      example = literalExpression ''
        [
          { name = "server1"; host = "user@server1"; localPort = 8385; }
          { name = "server2"; host = "user@server2"; localPort = 8386; }
        ]
      '';
    };
  };

  config = mkIf cfg.enable {
    home.packages = [ pkgs.syncthing ] ++ (if cfg.tunnels != [ ] then [ pkgs.autossh ] else [ ]);

    # Ensure sync directories exist and install .stignore files
    home.activation.setupSyncFolders = config.lib.dag.entryAfter [ "writeBoundary" ] ''
      ${concatMapStringsSep "\n" (
        folder:
        let
          expandedPath =
            if hasPrefix "~" folder.path then
              "${config.home.homeDirectory}${removePrefix "~" folder.path}"
            else
              folder.path;
        in
        ''
          mkdir -p "${expandedPath}"
          cp -f "${folder.stignore}" "${expandedPath}/.stignore"
        ''
      ) cfg.folders}
    '';
  };
}
