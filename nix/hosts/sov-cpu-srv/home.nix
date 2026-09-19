{
  imports = [
    ../../home-manager/common.nix
    ../../home-manager/bash-standalone.nix
    ../../home-manager/server.nix
    ../../home-manager/syncthing-nascent.nix
  ];

  home = {
    username = "jonathan";
    homeDirectory = "/home/jonathan";

    file.".bazelrc".text = ''
      startup --output_user_root=/datapool/jonathan/bazel
    '';
  };
}
