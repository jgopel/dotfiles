{ den, ... }:

{
  den.aspects.desktop.__functor =
    _:
    {
      noctaliaSettingsFile ? null,
    }:
    {
      name = "desktop";
      includes = [ (den.aspects.hyprland { settingsFile = noctaliaSettingsFile; }) ];
    };
}
