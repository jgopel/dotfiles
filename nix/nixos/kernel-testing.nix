{
  config,
  lib,
  pkgs,
  ...
}:

{
  # Keep the latest stable kernel while testing the Thunderbolt patch below.
  boot.kernelPackages = pkgs.linuxPackages_latest.extend (
    _final: prev: {
      kernel =
        (prev.kernel.override {
          stdenv = pkgs.ccacheStdenv.override {
            extraConfig = ''
              export CCACHE_DIR="${config.programs.ccache.cacheDir}"
              export CCACHE_UMASK=007
              export CCACHE_SLOPPINESS=random_seed
              export CCACHE_MAXSIZE=20G
            '';
          };
        }).overrideAttrs
          (old: {
            # Nixpkgs unpacks into $dev, whose hash changes with every patch.
            # Compile in /build/source instead so paths (including debug info)
            # stay stable without weakening ccache's input checks.
            preUnpack = "";
            postInstall = ''
              mkdir -p "$dev/lib/modules/${prev.kernel.modDirVersion}"
              mv "$NIX_BUILD_TOP/source" "$dev/lib/modules/${prev.kernel.modDirVersion}/source"
              cd "$dev/lib/modules/${prev.kernel.modDirVersion}/source"
            ''
            + old.postInstall;
          });
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
  ]
  # Temporary diagnostics for the XPS's intermittent s2idle hang.
  ++ lib.optionals (config.networking.hostName == "XPS-17-9720") [
    {
      name = "suspend-diagnostics";
      patch = ./suspend-diagnostics.patch;
    }
  ];
}
