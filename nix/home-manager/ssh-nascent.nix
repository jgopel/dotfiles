{
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;

    settings = {
      platform-tokyo-dev = {
        HostName = "platform-tokyo-dev";
        IdentityFile = "~/.ssh/ec2-dev-machine.pem";
        Compression = true;
        ForwardX11 = false;
      };

      sov-cpu-srv = {
        User = "jonathan";
      };

      shared-ib-fix-dev = {
        User = "jonathan";
      };

      us-east-1-data-gateway-1 = {
        HostName = "3.211.152.152";
        User = "ubuntu";
      };

      ap-northeast-1-data-gateway-1 = {
        HostName = "35.79.161.96";
        User = "ubuntu";
      };

      ap-northeast-1-data-gateway-2 = {
        HostName = "18.178.14.201";
        User = "ubuntu";
      };

      ap-northeast-1-data-gateway-3 = {
        HostName = "52.196.179.5";
        User = "ubuntu";
      };

      ap-northeast-1-data-gateway-4 = {
        HostName = "52.196.203.192";
        User = "ubuntu";
      };

      ap-northeast-1-data-gateway-5 = {
        HostName = "18.180.184.80";
        User = "ubuntu";
      };

      ap-northeast-1-data-gateway-6 = {
        HostName = "13.112.152.51";
        User = "ubuntu";
      };

      ap-northeast-1-data-gateway-7 = {
        HostName = "3.113.72.238";
        User = "ubuntu";
      };
    };
  };
}
