# AGENTS.md

Dotfiles repo managed by **Nix Home Manager (flakes)**.

## Commands

| Task                         | Command          |
| ---------------------------- | ---------------- |
| Quality checks (prek)        | `just quality`   |
| Initial Home Manager install | `just setup-nix` |

## Non-standard patterns

### Home Manager owns all symlinks

Config files land in `$HOME` via `home.file` / `xdg.configFile` in Nix
modules—not manual symlinks.

```nix
xdg.configFile."starship.toml".source = ./starship.toml;
```

### Host configuration and module selection

Each `nix/hosts/<hostname>/default.nix` declares den entities and their aspects.
NixOS machines declare `den.hosts.<system>.<hostname>.users.jonathan = { };` and
import the tracked `hardware-configuration.nix` through their host's `nixos`
aspect. Keep hardware settings and machine-specific workarounds in the host
directory.

Home Manager remains standalone, including on NixOS: each machine declares
`den.homes.<system>."user@hostname"`. Den selects both the user's base aspect
and `user@hostname` for host users and standalone homes. Select optional aspects
and set home state versions in that host-qualified aspect. HM-only machines have
no `den.hosts` entry. Leave host-user `classes` at its default `[ "user" ]` so
Home Manager is not also activated through NixOS.
