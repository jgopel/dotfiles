{ den, ... }:

{
  den.aspects.jonathan.desktop = {
    includes = [
      den.aspects."1pass".desktop
      den.aspects.agents.desktop
      den.aspects.firefox
      den.aspects.ghostty
      den.aspects.signal
      den.aspects.slack
    ];

    linux.__functor = _: { noctaliaSettingsFile }: {
      includes = [
        den.aspects.jonathan.desktop
        (den.aspects.desktop { inherit noctaliaSettingsFile; })
      ];
    };

    macos.includes = [
      den.aspects.jonathan.desktop
      den.aspects.macos
    ];

    provides.to-hosts.darwin.homebrew.casks = [
      "discord"
      "dropbox"
      "google-chrome"
      "keepassxc"
    ];

    homeManager = { pkgs, ... }: { home.packages = [ pkgs.hack-font ]; };

    hmLinux = { pkgs, ... }: {
      home.packages = with pkgs; [
        discord
        dropbox
        google-chrome
        keepassxc
      ];
    };
  };
}
