{ den, ... }:

{
  den.aspects.server = {
    includes = [
      den.aspects.mosh.server
      den.aspects.ssh.server
    ];
    provides.to-hosts.nixos = { user, ... }: { users.users.${user.userName}.linger = true; };
  };
}
