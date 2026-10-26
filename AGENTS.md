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

### Host configuration and module selection

Each `nix/hosts/<hostname>/default.nix` declares den entities and their aspects.
NixOS machines declare `den.hosts` and import `./configuration.nix` through
their `nixos` aspect. That configuration imports the tracked
`hardware-configuration.nix`; keep hardware settings and machine-specific
workarounds in the host directory.

Home Manager remains standalone, including on NixOS: each machine declares
`den.homes.<system>."user@hostname"` and imports `./home.nix` through its
host-qualified `homeManager` aspect. Existing `home.nix` files select modules,
identity, and host-specific settings. HM-only machines have `default.nix` and
`home.nix`, without a `den.hosts` entry.

### Hostname-based bash sourcing (`bash/`)

`.bashrc` sources `functions.sh` then conditionally includes
`.bashrc_$(hostname -s)` for per-machine overrides. Put machine-specific shell
config there, not in the main bashrc.

### Modules are in the process of being made dendratic

Legacy modules live in `nix/nixos` and `nix/home-manager`. The new dendratic
modules live in `nix/modules`.
