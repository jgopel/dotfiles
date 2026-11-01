{ pkgs, ... }:

{
  # INFO callback timings stay in the journal; NOTICE phase markers also reach
  # the console. Keeping consoles awake can change suspend timing/behaviour.
  boot.consoleLogLevel = 6;
  boot.kernelParams = [
    "pm_debug_messages"
    "no_console_suspend"
    "log_buf_len=8M"
  ];

  systemd.services.suspend-diagnostics = {
    description = "Enable suspend callback diagnostics";
    wantedBy = [ "multi-user.target" ];
    before = [ "sleep.target" ];
    serviceConfig.Type = "oneshot";
    serviceConfig.RemainAfterExit = true;
    script = ''
      echo 1 > /sys/power/pm_debug_messages
      echo 1 > /sys/power/pm_print_times
    '';
  };

  # Disk-backed, bounded history. A short sync interval reduces loss while
  # userspace runs; it cannot persist printk records while journald is frozen.
  services.journald.settings.Journal = {
    Storage = "persistent";
    SystemMaxUse = "50G";
    SystemKeepFree = "50G";
    SystemMaxFileSize = "256M";
    SyncIntervalSec = "1s";
    RateLimitIntervalSec = 0;
  };

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
