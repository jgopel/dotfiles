{ pkgs, ... }:

{
  programs.hyprland.package = pkgs.hyprland.overrideAttrs (old: {
    # Keep FALLBACK alive at startup until another output becomes usable.
    patches = (old.patches or [ ]) ++ [ ./hyprland-startup-fallback.patch ];
  });
}
