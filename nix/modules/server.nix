{ den, ... }:

{
  den.aspects.server = {
    includes = [
      den.aspects.mosh.server
      den.aspects.ssh.server
    ];
    user.linger = true;
  };
}
