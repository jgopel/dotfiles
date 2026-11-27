{ den, ... }:

{
  den.aspects."1pass" = {
    provides.to-hosts.nixos.programs._1password.enable = true;

    desktop = {
      includes = [ den.aspects."1pass" ];

      provides.to-hosts.darwin.homebrew.casks = [ "1password" ];

      provides.to-hosts.nixos.programs._1password-gui = {
        enable = true;
        polkitPolicyOwners = [ "jonathan" ];
      };
    };

    homeManager =
      {
        config,
        lib,
        pkgs,
        ...
      }:
      let
        cfg = config.programs.onepassword.account;
      in
      {
        options.programs.onepassword = {
          account = lib.mkOption {
            type = lib.types.submodule {
              options = {
                url = lib.mkOption {
                  type = lib.types.nullOr lib.types.str;
                  description = "1Password sign-in address; null means not configured.";
                };
                secrets = lib.mkOption {
                  type = lib.types.attrsOf (lib.types.nullOr (lib.types.strMatching "op://.+"));
                  description = "Secret references by environment variable; null means not configured.";
                };
              };
            };
            description = "1Password account and its available secret references.";
          };
        };

        config = {
          home.packages = [ pkgs._1password-cli ];
          xdg.configFile."fish/functions/__onepassword_launch.fish".source = ./__onepassword_launch.fish;

          assertions = lib.mapAttrsToList (name: _: {
            assertion = builtins.match "[A-Za-z_][A-Za-z0-9_]*" name != null;
            message = "Invalid 1Password environment variable name: ${name}";
          }) cfg.secrets;

          lib.onepassword.fishFunction =
            {
              command,
              secretNames,
              signInAttempts ? 5,
            }:
            assert lib.assertMsg (lib.types.ints.positive.check signInAttempts)
              "signInAttempts must be a positive integer";
            let
              fishArg = value: "'${lib.escape [ "\\" "'" ] (toString value)}'";
              op = pkgs.writeShellScript "interactive-op" ''
                # Fish aborts the calling function if its foreground job dies of SIGINT.
                trap 'exit 130' INT
                op=${lib.getExe' pkgs._1password-cli "op"}
                if [[ -x /run/wrappers/bin/op ]]; then op=/run/wrappers/bin/op; fi
                limit=$1; shift
                ${lib.getExe' pkgs.coreutils "timeout"} --foreground --kill-after=2s "$limit" "$op" "$@"
              '';
            in
            {
              wraps = builtins.baseNameOf command;
              body = ''
                set -l program ${fishArg command}
                set -l op ${op}
                set -l account ${fishArg cfg.url}
                set -l names ${lib.concatMapStringsSep " " fishArg secretNames}
                set -l references ${lib.concatMapStringsSep " " (name: fishArg cfg.secrets.${name}) secretNames}
                set -l sign_in_attempts ${toString signInAttempts}
                __onepassword_launch $argv
              '';
            };
        };
      };
  };
}
