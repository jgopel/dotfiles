{ config, pkgs, ... }:

{
  # Need 7.3 for the TS5Plus USB XHCI fix; return to linuxPackages_latest
  # once that release is available there.
  boot.kernelPackages = pkgs.linuxPackages_testing.extend (
    _final: prev: {
      kernel = prev.kernel.override {
        stdenv = pkgs.ccacheStdenv.override {
          extraConfig = ''
            export CCACHE_DIR="${config.programs.ccache.cacheDir}"
            export CCACHE_UMASK=007
            export CCACHE_SLOPPINESS=random_seed
            export CCACHE_MAXSIZE=20G
          '';
        };
      };
    }
  );

  # Keep the cache between patch revisions without changing other packages' compilers.
  programs.ccache.enable = true;
  nix.settings.extra-sandbox-paths = [ config.programs.ccache.cacheDir ];

  security.wrappers.nix-ccache.enable = false;

  # Bootstrap before the first rebuild (the new tmpfiles/nix.conf aren't active yet):
  # sudo install -d -m 0770 -o root -g nixbld /var/cache/ccache
  # sudo nixos-rebuild switch --flake . --option extra-sandbox-paths /var/cache/ccache

  # Test this Thunderbolt runtime-PM fix across hosts for upstream inclusion.
  boot.kernelPatches = [
    {
      name = "thunderbolt-rpm-subtree";
      patch = ./thunderbolt-rpm-subtree.patch;
    }
  ];
}
