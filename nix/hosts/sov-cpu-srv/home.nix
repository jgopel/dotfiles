{
  imports = [ ../../home-manager/common.nix ];

  home = {
    username = "jonathan";
    homeDirectory = "/home/jonathan";

    file.".bazelrc".text = ''
      startup --output_user_root=/datapool/jonathan/bazel
    '';
  };
}
