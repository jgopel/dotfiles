{
  lib,
  pkgs,
  inputs,
  ...
}:

let
  rust-bin = inputs.rust-overlay.lib.mkRustBin { } pkgs;
  rustToolchain = rust-bin.stable.latest.default.override {
    extensions = [
      "rust-src"
      "rust-analyzer"
      "clippy"
      "rustfmt"
    ];
  };
  rustNightly = rust-bin.nightly.latest.default;
  cargo-nightly = pkgs.writeShellScriptBin "cargo-nightly" ''
    export RUSTC="${rustNightly}/bin/rustc"
    export RUSTDOC="${rustNightly}/bin/rustdoc"
    exec ${rustNightly}/bin/cargo "$@"
  '';
in
{
  home.packages = with pkgs; [
    bacon
    cargo-nextest
    cargo-nightly
    rustToolchain
  ];

  home.sessionPath = lib.mkAfter [ "$HOME/.cargo/bin" ];

  xdg.configFile."bacon/prefs.toml".source = ../../bacon/prefs.toml;
}
