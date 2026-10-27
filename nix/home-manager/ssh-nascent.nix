{
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;

    settings = {
      platform-tokyo-dev = {
        HostName = "platform-tokyo-dev";
        Compression = true;
        ForwardX11 = false;
      };

      sov-cpu-srv = {
        User = "jonathan";
      };

      shared-ib-fix-dev = {
        User = "jonathan";
      };
    };
  };
}
