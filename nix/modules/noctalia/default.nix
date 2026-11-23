{ repoRoot, ... }:

{
  den.aspects.noctalia.__functor = _: { settingsFile }: {
    name = "noctalia";
    provides.to-hosts.nixos.services = {
      displayManager.noctalia-greeter.enable = true;
      upower.enable = true;
    };

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
          settings = import ./settings.nix { inherit inputs pkgs; };
        };

        home.packages = [
          pkgs.lua5_5
          pkgs.util-linux
        ];

        home.file."${config.xdg.stateHome}/noctalia/settings.toml".source =
          let
            # Target the live checkout so Noctalia can save settings from its UI.
            relativePath = lib.removePrefix "${toString repoRoot}/" (toString settingsFile);
          in
          config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/${relativePath}";
      };
  };
}
