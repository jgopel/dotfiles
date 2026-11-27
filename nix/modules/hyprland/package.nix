{
  inputs,
  repoRoot,
  lib,
  noctalia,
  writeShellApplication,
  writeText,
  adwaita-icon-theme,
  ghostty,
  gnugrep,
  hyprland,
  jq,
}:

let
  layouts = writeShellApplication {
    name = "hyprland-layouts";
    runtimeInputs = [
      noctalia
      hyprland
    ];
    text = builtins.readFile (repoRoot + /hyprland/layouts.sh);
  };
  monitors = writeShellApplication {
    name = "hyprland-monitors";
    runtimeInputs = [
      gnugrep
      hyprland
      jq
    ];
    text = builtins.readFile (repoRoot + /hyprland/monitors.sh);
  };
  appearance = writeText "appearance.lua" (
    lib.replaceStrings
      [ "@icons@" "@futurista@" ]
      [
        "${adwaita-icon-theme}/share/icons"
        "${inputs.noctalia-plugins}/hyprland-settings/lib/presets/futurista.luau"
      ]
      (builtins.readFile (repoRoot + /hyprland/appearance.lua))
  );
  bindings = writeText "bindings.lua" (
    lib.replaceStrings
      [ "@noctalia@" "@layouts@" "@terminal@" ]
      [
        "${noctalia}/bin/noctalia"
        "${layouts}/bin/hyprland-layouts"
        "${ghostty}/bin/ghostty --gtk-single-instance=true"
      ]
      (builtins.readFile (repoRoot + /hyprland/bindings.lua))
  );
  monitorConfig = writeText "monitors.lua" (
    lib.replaceStrings [ "@monitors@" ] [ "${monitors}/bin/hyprland-monitors" ] (
      builtins.readFile (repoRoot + /hyprland/monitors.lua)
    )
  );
in
{
  inherit layouts;
  config = writeText "hyprland.lua" (
    lib.replaceStrings
      [
        "@appearance@"
        "@bindings@"
        "@scrolling@"
        "@window-rules@"
        "@workspace-layouts@"
        "@workspace-bar@"
        "@workspace-navigation@"
        "@monitors@"
      ]
      [
        "${appearance}"
        "${bindings}"
        "${repoRoot + /hyprland/scrolling.lua}"
        "${repoRoot + /hyprland/window-rules.lua}"
        "${repoRoot + /hyprland/workspace-layouts.lua}"
        "${repoRoot + /hyprland/workspace-bar.lua}"
        "${repoRoot + /hyprland/workspace-navigation.lua}"
        "${monitorConfig}"
      ]
      (builtins.readFile (repoRoot + /hyprland/hyprland.lua))
  );
}
