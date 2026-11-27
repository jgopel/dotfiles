{ lib, repoRoot, ... }:

{
  den.aspects.noctalia.__functor =
    _:
    {
      settingsFile,
      fingerprintUnlock ? false,
    }:
    {
      name = "noctalia";
      provides.to-hosts.nixos = {
        security.pam.services = {
          # greetd delegates sign-in to login; require a password even on reader-equipped hosts.
          login = {
            allowNullPassword = lib.mkForce false;
            fprintAuth = false;
          };
          noctalia.fprintAuth = false;
        };
        services = {
          displayManager.noctalia-greeter.enable = true;
          # The lock screen talks directly to fprintd; no PAM prompt should wait for a scan.
          fprintd = lib.mkIf fingerprintUnlock {
            enable = true;
            enablePam = false;
          };
          upower.enable = true;
        };
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
            package = inputs.noctalia.packages.${pkgs.stdenv.hostPlatform.system}.default.overrideAttrs (old: {
              mesonFlags = old.mesonFlags ++ [ "-Dpam_service=noctalia" ];
            });
            systemd.enable = true;
            settings = import ./settings.nix { inherit inputs pkgs fingerprintUnlock; };
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
