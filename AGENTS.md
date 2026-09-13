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

NixOS hosts live in `nix/hosts/<hostname>/configuration.nix`, alongside their
`hardware-configuration.nix`. Each host explicitly imports its system modules;
keep hardware settings and machine-specific workarounds in the host directory.

Home Manager remains independent: each `nix/hosts/<hostname>/home.nix` imports
`nix/home-manager/common.nix` and selects user modules, identity, and
host-specific settings. Hosts without NixOS need only `home.nix`.

`nix/hosts/default.nix` discovers immediate host directories:
`configuration.nix` exports `nixosConfigurations."hostname"`, and `home.nix`
exports `homeConfigurations."user@hostname"` using its evaluated
`home.username`. `flake.nix` supplies shared dependencies and the current
`x86_64-linux` package setup, without listing hosts. Add new host files to Git
so flake discovery can see them; no registry edit is needed.

### Hostname-based bash sourcing (`bash/`)

`.bashrc` sources `functions.sh` then conditionally includes
`.bashrc_$(hostname -s)` for per-machine overrides. Put machine-specific shell
config there, not in the main bashrc.

### Modules are composable (`nix/`)

Keep NixOS modules in `nix/nixos/` and Home Manager modules in
`nix/home-manager/`. Compose them with explicit `imports` lists. Prefer focused
modules over growing `common.nix` or host configurations.
