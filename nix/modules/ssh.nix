{ den, ... }:

{
  den.aspects.ssh = {
    homeManager = { pkgs, ... }: {
      home.packages = [ pkgs.openssh_gssapi ];

      services.ssh-agent.enable = true;
    };

    nascent = {
      includes = [ den.aspects.ssh ];

      homeManager.programs.ssh = {
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

        };
      };
    };

    personal = {
      includes = [ den.aspects.ssh ];

      homeManager.programs.ssh = {
        enable = true;
        enableDefaultConfig = false;

        settings = {
          mnemosyne = {
            User = "root";
          };
        };
      };
    };
  };
}
