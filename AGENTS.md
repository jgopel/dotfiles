# AGENTS.md

Dotfiles repo managed by **Nix Home Manager (flakes)**.

## Commands

| Task                         | Command          |
| ---------------------------- | ---------------- |
| Quality checks (prek)        | `make quality`   |
| Initial Home Manager install | `make setup-nix` |

## Non-standard patterns

### Home Manager owns all symlinks

Config files land in `$HOME` via `home.file` / `xdg.configFile` in Nix
modules—not manual symlinks.

```nix
xdg.configFile."starship.toml".source = ./starship.toml;
```

### Host-specific configs in `flake.nix`

Each machine is a `homeConfigurations."user@hostname"` entry selecting which
modules to include. Add new machines by following that pattern with appropriate
`extraSpecialArgs`.

### Hostname-based bash sourcing (`bash/`)

`.bashrc` sources `functions.sh` then conditionally includes
`.bashrc_$(hostname -s)` for per-machine overrides. Put machine-specific shell
config there, not in the main bashrc.

### Modules are composable (`modules/`)

Prefer adding focused Nix modules or extending existing ones over growing
`home.nix`.
