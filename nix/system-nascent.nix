{
  nix.settings = {
    trusted-substituters = [ "https://sovereign-systematic.cachix.org" ];
    extra-trusted-public-keys = [
      "sovereign-systematic.cachix.org-1:UZPYcDIEyhbSY0bswZXI2c+vosUCNa7tBYt1xn/ut1Q="
    ];
  };
}
