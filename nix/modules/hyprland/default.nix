{ den, repoRoot, ... }:

{
  den.aspects.hyprland.__functor = _: noctaliaOptions: {
    name = "hyprland";
    includes = [ (den.aspects.noctalia noctaliaOptions) ];

    provides.to-hosts.nixos.programs.hyprland.enable = true;

    homeManager =
      {
        pkgs,
        inputs,
        config,
        lib,
        ...
      }:

      let
        desktop = pkgs.callPackage ./package.nix {
          inherit inputs repoRoot;
          noctalia = config.programs.noctalia.package;
        };
      in
      {
        home.packages = [ desktop.layouts ];

        programs.noctalia.settings.hooks.session_unlocked =
          "${pkgs.hyprland}/bin/hyprctl eval 'reconcile_monitors()'";

        home.activation.hyprlandSettings = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
          run mkdir -p ${lib.escapeShellArg "${config.xdg.configHome}/hypr"}
          if [[ ! -e ${lib.escapeShellArg "${config.xdg.configHome}/hypr/hyprland-settings.lua"} ]]; then
            run touch ${lib.escapeShellArg "${config.xdg.configHome}/hypr/hyprland-settings.lua"}
          fi
        '';

        wayland = {
          systemd.target = "hyprland-session.target";
          windowManager.hyprland = {
            enable = true;
            package = null;
            portalPackage = null;
            configType = "lua";
            systemd.enable = true;
            extraConfig = ''
              dofile("${desktop.config}")
            '';
          };
        };
      };
  };
}
