{
  inputs,
  lib,
  stdenv,
  writeShellApplication,
  writeText,
  adwaita-icon-theme,
  ghostty,
  hyprland,
}:

let
  noctalia = inputs.noctalia.packages.${stdenv.hostPlatform.system}.default;
  layouts = writeShellApplication {
    name = "hyprland-layouts";
    runtimeInputs = [
      noctalia
      hyprland
    ];
    text = ''
      choice=$(printf '%s\n' 'Two columns' 'Scrolling' 'Dwindle' 'Monocle' | noctalia dmenu -p 'Workspace layout') || exit 0
      case "$choice" in
        'Two columns') layout=two-column ;;
        'Scrolling') layout=scrolling ;;
        'Dwindle') layout=dwindle ;;
        'Monocle') layout=monocle ;;
        *) exit 0 ;;
      esac
      hyprctl eval "set_workspace_layout(\"$layout\")"
    '';
  };
  appearance = writeText "appearance.lua" (
    lib.replaceStrings [ "@icons@" ] [ "${adwaita-icon-theme}/share/icons" ] (
      builtins.readFile ./appearance.lua
    )
  );
  bindings = writeText "bindings.lua" (
    lib.replaceStrings
      [ "@noctalia@" "@layouts@" "@terminal@" ]
      [
        "${noctalia}/bin/noctalia"
        "${layouts}/bin/hyprland-layouts"
        "${ghostty}/bin/ghostty --gtk-single-instance=true"
      ]
      (builtins.readFile ./bindings.lua)
  );
in
{
  inherit noctalia layouts;
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
      ]
      [
        "${appearance}"
        "${bindings}"
        "${./scrolling.lua}"
        "${./window-rules.lua}"
        "${./workspace-layouts.lua}"
        "${./workspace-bar.lua}"
        "${./workspace-navigation.lua}"
      ]
      (builtins.readFile ./hyprland.lua)
  );
}
