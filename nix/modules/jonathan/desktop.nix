{ den, ... }:

{
  den.aspects.jonathan.desktop.__functor =
    _:
    {
      noctaliaSettingsFile ? null,
    }:
    {
      # Keep the parameterized instance identifiable by the Nascent composition rule.
      name = "desktop";
      meta.aspect-chain = [ "jonathan" ];
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
