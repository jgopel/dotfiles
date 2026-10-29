{ repoRoot, ... }:

{
  den.aspects.noctalia.__functor =
    _:
    {
      settingsFile ? null,
    }:
    {
      name = "noctalia";
      homeManager =
        {
          config,
          inputs,
          lib,
          pkgs,
          ...
        }:
        {
          imports = [ inputs.noctalia.homeModules.default ];

          programs.noctalia = {
            enable = true;
            systemd.enable = true;
            settings = import ./noctalia/settings.nix { inherit inputs; };
          };

          home.packages = [
            pkgs.lua5_5
            pkgs.util-linux
          ];

          home.file = lib.optionalAttrs (settingsFile != null) {
            "${config.xdg.stateHome}/noctalia/settings.toml".source =
              let
                # Target the live checkout so Noctalia can save settings from its UI.
                relativePath = lib.removePrefix "${toString repoRoot}/" (toString settingsFile);
              in
              config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/${relativePath}";
          };
        };
    };
}
