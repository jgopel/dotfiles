{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:

{
  imports = [ inputs.swifteam.outPath ];

  services.swifteam = {
    enable = true;
    teamId = "681237983000002c00bcd68b";
    name = "Jonathan";
    surname = "Gopel";
    email = "jonathan@nascent.xyz";
    nixRootPath = "/home/jonathan/dotfiles/nix";
  };

  # NOTE: Swif ships with a baked-in hashed password for the sudo-enabled
  # account that it creates. This is presumably to open some sort of back door
  # into the system, but Pascal doesn't think he needs that so I'm just locking
  # it out. If someone ever needs it, I'm sure I'll find out.
  users.users.swifteam.hashedPassword = "!";

  systemd.services = lib.mkIf config.services.swifteam.enable {
    swif-agent-installer = {
      # Run the wrapper on every boot. It skips enrollment when installed.flag
      # exists, but the post-start hook must still start the agents in that case.
      unitConfig.ConditionPathExists = lib.mkForce "";
      postStart = ''
        ${pkgs.systemd}/bin/systemctl --no-block start swif-agent.service syscheck.service
      '';
    };

    # The installer starts the agents after enrollment and waits for them to be
    # active before writing installed.flag. Neither After=installer nor a flag
    # condition can gate them. Remove automatic boot startup instead, so only the
    # installer (or its post-start hook on later boots) starts them.
    swif-agent = {
      wantedBy = lib.mkForce [ ];
      unitConfig.ConditionPathExists = lib.mkForce "";
    };
    syscheck = {
      wantedBy = lib.mkForce [ ];
      unitConfig.ConditionPathExists = lib.mkForce "";
    };
  };
}
