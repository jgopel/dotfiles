{ den, ... }:

{
  den.aspects.jonathan.desktop.__functor = _: { noctaliaSettingsFile }: {
    includes = [
      (den.aspects.desktop { inherit noctaliaSettingsFile; })
      den.aspects."1pass".desktop
      den.aspects.agents.desktop
      den.aspects.firefox
      den.aspects.ghostty
      den.aspects.signal
      den.aspects.slack
    ];

    homeManager = { pkgs, ... }: {
      home.packages = with pkgs; [
        discord
        dropbox
        google-chrome
        hack-font
        keepassxc
      ];
    };
  };
}
