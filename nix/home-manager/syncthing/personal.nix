{
  imports = [ ../syncthing.nix ];

  services.syncthing-user = {
    enable = true;
    clusters = [ "personal" ];
    folders = [
      {
        path = "~/personal";
        stignore = ../../../syncthing/stignore-personal;
      }
    ];
  };
}
