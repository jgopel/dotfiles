{
  common = {
    extra-substituters = [
      "https://cache.numtide.com"
      "https://nix-community.cachix.org"
      "https://devenv.cachix.org"
      "https://noctalia.cachix.org"
      "https://jonathan.cachix.org"
    ];
    extra-trusted-public-keys = [
      "niks3.numtide.com-1:DTx8wZduET09hRmMtKdQDxNNthLQETkc/yaX7M4qK0g="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw="
      "noctalia.cachix.org-1:pCOR47nnMEo5thcxNDtzWpOxNFQsBRglJzxWPp3dkU4="
      "jonathan.cachix.org-1:aCu0qEoqdLs+Qmq9udXYcB5YISRuipb0XVxlpUx0PnE="
    ];
  };

  nascent = {
    trusted-substituters = [ "https://sovereign-systematic.cachix.org" ];
    extra-trusted-public-keys = [
      "sovereign-systematic.cachix.org-1:UZPYcDIEyhbSY0bswZXI2c+vosUCNa7tBYt1xn/ut1Q="
    ];
  };
}
