{ den, ... }:

{
  den.aspects.hyprland.__functor =
    _:
    {
      settingsFile ? null,
    }:
    {
      name = "hyprland";
      includes = [ (den.aspects.noctalia { inherit settingsFile; }) ];

      nixos.programs.hyprland.enable = true;

      homeManager =
        {
          pkgs,
          inputs,
          config,
          lib,
          ...
        }:

        let
          desktop = pkgs.callPackage ./hyprland/package.nix { inherit inputs; };
          monitors = pkgs.writeShellApplication {
            name = "hyprland-monitors";
            runtimeInputs = with pkgs; [
              gnugrep
              hyprland
              jq
            ];
            text = builtins.readFile ./hyprland/monitors.sh;
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
                hl.bind("SUPER + B", hl.dsp.exec_cmd("${desktop.noctalia}/bin/noctalia msg session lock"))

                local monitor_generation = 0
                -- A new event supersedes pending retries while dock outputs settle.
                function reconcile_monitors()
                  monitor_generation = monitor_generation + 1
                  local generation = monitor_generation
                  for _, delay in ipairs({ 1, 1000, 3000, 7000 }) do
                    hl.timer(function()
                      if generation == monitor_generation then
                        hl.exec_cmd("${monitors}/bin/hyprland-monitors")
                      end
                    end, { timeout = delay, type = "oneshot" })
                  end
                end
                for _, event in ipairs({
                  "hyprland.start", "config.reloaded", "monitor.added",
                  "monitor.removed", "monitor.layout_changed",
                }) do
                  hl.on(event, reconcile_monitors)
                end
                for _, state in ipairs({ "on", "off" }) do
                  hl.bind("switch:" .. state .. ":Lid Switch", reconcile_monitors, { locked = true })
                end
              '';
            };
          };
        };
    };
}
