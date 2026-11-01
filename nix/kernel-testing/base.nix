{ config, pkgs, ... }:

let
  # All enabled test patches target this base; select a release or RC here.
  baseKernelPackages = pkgs.linuxPackages_latest;
in
{
  boot.kernelPackages = baseKernelPackages.extend (
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
}
