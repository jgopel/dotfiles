{ pkgs, ... }:

{
  # Keep this diagnostic recorder local to the XPS. Userspace cannot drain
  # ftrace while frozen, so a forced power-off can still lose the final events.
  systemd.services.suspend-trace = {
    description = "Rolling suspend trace recorder";
    wantedBy = [ "multi-user.target" ];
    requires = [ "sys-kernel-tracing.mount" ];
    after = [ "sys-kernel-tracing.mount" ];

    serviceConfig = {
      ExecStart = "${pkgs.python3}/bin/python3 ${./suspend-trace.py} /sys/kernel/tracing/instances/suspend-debug /var/lib/suspend-trace";
      StateDirectory = "suspend-trace";
      StateDirectoryMode = "0700";
      UMask = "0077";
      Restart = "on-failure";
      RestartSec = "10s";
      NoNewPrivileges = true;
    };
  };
}
