{ den, lib, ... }:

{
  den = {
    classes = {
      hmLinux = { };
      hmDarwin = { };
    };

    # Select the class before module evaluation, preserving imports and options.
    policies.home-manager-platform = { home, ... }: [
      (den.lib.policy.route {
        fromClass =
          {
            linux = "hmLinux";
            darwin = "hmDarwin";
          }
          .${(lib.systems.elaborate home.system).parsed.kernel.name};
        intoClass = "homeManager";
      })
    ];

    aspects.home-manager = {
      includes = [ den.policies.home-manager-platform ];

      homeManager = { config, pkgs, ... }: {
        programs.home-manager.enable = true;

        home.activation.report-changes = config.lib.dag.entryAnywhere ''
          if [[ -n "''${oldGenPath:-}" ]]; then
            ${pkgs.nvd}/bin/nvd diff "$oldGenPath" "$newGenPath" || true
          fi
        '';
      };
    };
  };
}
