{ den, ... }:

{
  den = {
    hosts.x86_64-linux.mnemosyne-guest.users.jonathan = { };
    homes.x86_64-linux."jonathan@mnemosyne-guest".nixInstallation = "nixos";

    aspects = {
      mnemosyne-guest = {
        includes = [ den.aspects.unraid-guest ];
        nixos = {
          imports = [ ./hardware-configuration.nix ];

          networking.hostName = "mnemosyne-guest";
          system.stateVersion = "26.05";
        };
      };
      "jonathan@mnemosyne-guest" = {
        includes = [
          den.aspects.docker
          den.aspects.server
          den.aspects.jonathan.personal
          den.aspects.jonathan.personal-sync
        ];
        # TODO: Remove once the key is in ~/.ssh/authorized_keys. This key
        # already logs in, so copy it with `ssh-copy-id -f mnemosyne-guest`.
        user.openssh.authorizedKeys.keys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGCX9KjSY8niuP8TJymQjreCMEHSH8dCfzdcNjWgv57l jonathan@nixos"
        ];
        homeManager.home.stateVersion = "26.05";
      };
    };
  };
}
