{
  den.aspects.editor-tools.homeManager = { pkgs, ... }: {
    home.packages = with pkgs; [
      lua-language-server
      (mdformat.withPlugins (
        ps: with ps; [
          mdformat-gfm
          mdformat-frontmatter
        ]
      ))
      prettier
      shellcheck
      shfmt
      stylua
    ];
  };
}
