{ den, ... }:

{
  den.aspects."1pass" = {
    provides.to-hosts.nixos.programs._1password.enable = true;

    desktop = {
      includes = [ den.aspects."1pass" ];

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

          assertions = lib.mapAttrsToList (name: _: {
            assertion = builtins.match "[A-Za-z_][A-Za-z0-9_]*" name != null;
            message = "Invalid 1Password environment variable name: ${name}";
          }) cfg.secrets;

          lib.onepassword.wrap =
            {
              name,
              package,
              command,
              secretNames,
              skipArguments ? [ ],
            }:
            let
              variables = lib.genAttrs secretNames (name: cfg.secrets.${name});
              configuration = ''
                account=${lib.escapeShellArg (if cfg.url == null then "" else cfg.url)}
                cache_key=${builtins.hashString "sha256" (if cfg.url == null then "" else cfg.url)}
                names=(${lib.escapeShellArgs (builtins.attrNames variables)})
                references=(${
                  lib.escapeShellArgs (
                    map (value: if value == null then "" else value) (builtins.attrValues variables)
                  )
                })
                skip_arguments=(${lib.escapeShellArgs skipArguments})
              '';
              launcher = pkgs.writeShellScript "${command}-with-1password" (
                builtins.replaceStrings
                  [ "@configuration@" "@op@" "@timeout@" "@coreutils@" "@flock@" ]
                  [
                    configuration
                    "${pkgs._1password-cli}/bin/op"
                    "${pkgs.coreutils}/bin/timeout"
                    "${pkgs.coreutils}"
                    "${pkgs.flock}/bin/flock"
                  ]
                  (builtins.readFile ./launch.sh)
              );
            in
            pkgs.writeShellScriptBin name ''
              exec ${launcher} ${lib.escapeShellArg "${package}/bin/${command}"} "$@"
            '';
        };
      };
  };
}
