{
  den.aspects.bazel.__functor =
    _:
    {
      outputUserRoot ? null,
    }:
    {
      name = "bazel";
      homeManager =
        { lib, pkgs, ... }:
        let
          bazel = pkgs.symlinkJoin {
            name = "bazel";
            paths = [ pkgs.bazelisk ];
            postBuild = ''
              ln -s bazelisk "$out/bin/bazel"
            '';
          };
        in
        {
          home.packages = [ bazel ];

          home.file.".bazelrc" = lib.mkIf (outputUserRoot != null) {
            text = ''
              startup --output_user_root=${lib.escapeShellArg outputUserRoot}
            '';
          };

          xdg.dataFile =
            lib.genAttrs [ "bash-completion/completions/bazel" "bash-completion/completions/bazelisk" ]
              (_: {
                text = ''
                  source <(${lib.getExe pkgs.bazelisk} completion bash)
                  if declare -F _bazel__complete >/dev/null; then
                    complete -o nospace -F _bazel__complete bazel bazelisk
                  fi
                '';
              });

          xdg.configFile."fish/completions/bazel.fish".text = ''
            ${lib.getExe pkgs.bazelisk} completion fish | source
          '';

          programs.fish.interactiveShellInit = ''
            complete -c bazelisk --wraps bazel
          '';
        };
    };
}
