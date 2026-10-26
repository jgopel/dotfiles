{
  imports = [ ../../home-manager/common.nix ];

  home = {
    file.".bazelrc".text = ''
      startup --output_user_root=/datapool/jonathan/bazel
    '';
  };
}
