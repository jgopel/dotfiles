{ den, ... }:

{
  den.aspects.ssh = {
    homeManager = { pkgs, ... }: {
      home.packages = [ pkgs.openssh_gssapi ];

      services.ssh-agent.enable = true;
    };

    server.provides.to-hosts.nixos.services.openssh = {
      enable = true;
      settings = {
        PasswordAuthentication = false;
        KbdInteractiveAuthentication = false;
        PermitRootLogin = "no";
      };
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
