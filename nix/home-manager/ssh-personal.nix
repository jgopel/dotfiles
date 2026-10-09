{
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;

    settings = {
      mnemosyne = {
        User = "root";
      };
    };
  };
}
