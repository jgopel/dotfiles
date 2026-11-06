{ pkgs, ... }:

{
  # Deterministic reproduction of the suspected Atlantic double napi_disable
  # hang on the XPS dock. A separate boot entry keeps the test hook out of the
  # everyday kernel; it inherits the parent's diagnostic patches and settings.
  specialisation.atlantic-resume-removal-repro.configuration = {
    boot.kernelPatches = [
      {
        name = "atlantic-resume-removal-repro";
        patch = ./atlantic-resume-removal-repro.patch;
      }
    ];

    environment.systemPackages = [
      (pkgs.writeShellApplication {
        name = "atlantic-resume-removal-repro";
        runtimeInputs = with pkgs; [
          coreutils
          gnugrep
          gnused
          iproute2
          networkmanager
          systemd
          util-linux
        ];
        text = builtins.readFile ./atlantic-resume-removal-repro.sh;
      })
    ];
  };
}
