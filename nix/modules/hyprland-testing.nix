{
  den.aspects.hyprland-testing.nixos = { pkgs, ... }: {
    programs.hyprland.package = pkgs.hyprland.overrideAttrs (old: {
      # Keep FALLBACK alive at startup until another output becomes usable.
      patches = (old.patches or [ ]) ++ [ ./hyprland/hyprland-startup-fallback.patch ];
    });
  };
}
