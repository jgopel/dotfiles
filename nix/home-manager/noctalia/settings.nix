{ inputs }:

{
  shell = {
    polkit_agent = true;
    launch_apps_as_systemd_services = true;
  };
  plugins = {
    source = [
      {
        name = "community";
        kind = "path";
        location = "${inputs.noctalia-plugins}";
      }
    ];
  };
}
