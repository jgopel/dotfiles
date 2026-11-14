{ den, ... }:

{
  den = {
    homes.x86_64-linux."jonathan@ip-172-31-2-254".nixInstallation = "multi-user";
    aspects."jonathan@ip-172-31-2-254" = {
      includes = [
        den.aspects.jonathan.agents
        den.aspects.jonathan.dev
        den.aspects.jonathan.nascent
        den.aspects.server
      ];
      homeManager = {
        home.stateVersion = "26.05";
        programs.onepassword.account = {
          url = "https://sovereign-trading.1password.com";
          secrets.OPENROUTER_API_KEY = "op://Employee/env-openrouter/credential";
        };
      };
    };
  };
}
