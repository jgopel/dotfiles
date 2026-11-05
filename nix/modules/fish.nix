{ repoRoot, ... }:

{
  den.aspects.fish = {
    provides.to-hosts.nixos.programs.fish.enable = true;

    homeManager = { pkgs, ... }: {
      home.packages = with pkgs.fishPlugins; [ done ];

      xdg.configFile = {
        # Direct Fish logins skip /etc/profile. Initialize Nix before plugin snippets.
        "fish/conf.d/00-nix-daemon.fish".source = repoRoot + /fish/00-nix-daemon.fish;

        "fish/completions/devenv.fish".source =
          "${pkgs.devenv}/share/fish/vendor_completions.d/devenv.fish";
      };

      programs.fish = {
        enable = true;

        plugins = [
          {
            name = "loadenv";
            src = pkgs.fetchFromGitHub {
              owner = "berk-karaal";
              repo = "loadenv.fish";
              rev = "v1.1.0";
              sha256 = "sha256-+DmAnmHXHYlHjH95eMjPx2RBvt3BK5uNp+OjnM3QXO0=";
            };
          }
        ];

        shellInit = builtins.readFile (repoRoot + /fish/config.fish);
        interactiveShellInit = builtins.readFile (repoRoot + /fish/interactive.fish);
      };
    };
  };
}
