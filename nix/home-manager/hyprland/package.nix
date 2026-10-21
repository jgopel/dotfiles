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
      choice=$(printf '%s\n' 'Two columns' 'Three columns' 'Scrolling' | noctalia dmenu -p 'Workspace layout') || exit 0
      case "$choice" in
        'Two columns') layout=two-column ;;
        'Three columns') layout=three-column ;;
        'Scrolling') layout=scrolling ;;
        *) exit 0 ;;
      esac
      hyprctl eval "set_workspace_layout(\"$layout\")"
    '';
  };
in
{
  inherit noctalia layouts;
  config = writeText "hyprland.lua" (
    lib.replaceStrings
      [
        "@noctalia@"
        "@layouts@"
        "@terminal@"
        "@icons@"
        "@workspace-layouts@"
        "@workspace-bar@"
        "@workspace-navigation@"
      ]
      [
        "${noctalia}/bin/noctalia"
        "${layouts}/bin/hyprland-layouts"
        "${ghostty}/bin/ghostty --gtk-single-instance=true"
        "${adwaita-icon-theme}/share/icons"
        "${./workspace-layouts.lua}"
        "${./workspace-bar.lua}"
        "${./workspace-navigation.lua}"
      ]
      (builtins.readFile ./hyprland.lua)
  );
}
