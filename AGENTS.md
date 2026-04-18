# AGENTS.md

A guide for AI coding agents working in this Nix flake repository.

## Project Overview

Multi-host Nix flake managing NixOS desktops, macOS via nix-darwin, and a home server cluster — all sharing a common Home Manager configuration. Secrets are encrypted with sops-nix + age.

## Key Commands

```fish
# Apply config on current host (works on any machine)
nix-switch   # alias for: sudo nixos-rebuild switch --flake ~/.config/nix#(hostname -s)
             #        or: sudo darwin-rebuild switch --flake .#(hostname -s)

# Check flake without building (NixOS) / eval toplevel (macOS)
nix-check

# Validate flake inputs and locks
nix flake check --no-build

# Format Nix files
nixfmt <file>    # managed via nixvim, runs nixfmt

# Enter dev shell if defined
nix develop
```

## Repo Layout

```
flake.nix                  # Entry point — defines all hosts via mkSystem
hosts/<hostname>/          # Per-host configuration.nix + hardware-configuration.nix
nixos/                     # Shared NixOS system modules (audio, fonts, sops, tailscale…)
nixos/roles/               # Optional services (Gitea, Matrix, Vaultwarden, AdGuard…)
darwin/                    # macOS-only system modules (fonts, homebrew, yabai, sketchybar)
home/                      # Shared Home Manager config (all hosts, both platforms)
home/desktop/              # Desktop-only home modules — Linux (hyprland/niri, waybar, rofi…)
home/desktop/sketchybar/   # macOS-only bar config
home/neovim/               # nixvim configuration split by plugin
assets/                    # Wallpapers and avatar images — do not modify programmatically
secrets/                   # age-encrypted secrets — never edit .age files directly
```

## Hosts

| Hostname | Platform | Type | Notes |
|---|---|---|---|
| cyper-desktop | NixOS x86_64 | Desktop | Primary Linux workstation |
| cyper-mac | macOS x86_64 | Desktop | nix-darwin + Homebrew |
| cyper-controller | NixOS x86_64 | Server | Runs all roles/services |
| cyper-node-1 | NixOS x86_64 | Server | `isServer = true` |
| cyper-node-2 | NixOS x86_64 | Server | `isServer = true` |

## mkSystem Convention

All hosts are built via `mkSystem` in `flake.nix`. Key flags:

- `isDarwin = true` → uses `darwin.lib.darwinSystem` + darwin modules
- `isServer = true` → skips desktop/GUI modules; both flags are passed as `specialArgs` to all modules via `sharedSpecialArgs`

Guard platform-specific code with:

```nix
if isDarwin then { ... } else { ... }
if isServer then { ... } else { ... }
```

## Home Manager

A single `home/` tree is shared by all hosts. Desktop-only modules live under `home/desktop/` and are conditionally included. The `isDarwin` and `isServer` flags are available as `specialArgs` inside Home Manager modules.

## Secrets

Managed with [sops-nix](https://github.com/Mic92/sops-nix) + age encryption.

- **Never edit `.age` files directly** — use `sops secrets/secrets.yaml`
- Age key must exist at `~/.config/sops/age/keys.txt` on every host
- Public keys are declared in `secrets/keys.txt.age` and `.sops.yaml` (if present)
- Secrets are referenced in Nix via `config.sops.secrets.<name>.path`

## Conventions

- **Formatter:** `nixfmt` (run via nixvim; apply before committing)
- **No `hardware-configuration.nix` edits** — these are machine-generated; regenerate with `nixos-generate-config` if needed
- **Homebrew** is managed declaratively via `darwin/homebrew.nix` — do not run `brew install` manually
- **Catppuccin** theming is applied system-wide via `home/catppuccin.nix` and `nixos/catppuccin.nix`; keep theme tokens consistent across modules
- **Shell is Fish** — shell aliases and functions live in `home/shell.nix`; use fish syntax

## Adding a New Host

1. Create `hosts/<hostname>/configuration.nix` (and `hardware-configuration.nix` for NixOS)
2. Add an entry to `nixosConfigurations` (or `darwinConfigurations`) in `flake.nix` via `mkSystem`
3. Add the host to the machines table in `README.md` and this file

## Adding a New Role/Service

1. Create `nixos/roles/<service>.nix`
2. Import it in the relevant host's `configuration.nix` or in `nixos/default.nix` behind an `isServer` guard
3. Add any required secrets to `secrets/secrets.yaml` via `sops`

## PR Checklist

- [ ] `nix flake check --no-build` passes
- [ ] `nixfmt` applied to changed `.nix` files
- [ ] No hardcoded paths or usernames — use `primaryUser` / `hostName` from `specialArgs`
- [ ] Secrets referenced via sops, not inlined
- [ ] `hardware-configuration.nix` untouched unless intentional
- [ ] README and AGENTS.md updated if hosts, roles, or structure changed

## Gotchas

- `primaryUser` is defined in `flake.nix` and injected everywhere via `sharedSpecialArgs` — never hardcode the username
- `home-manager.backupFileExtension = "backup"` is set globally; conflicts create `.backup` files rather than erroring
- The `l` fish function calls a Groq LLM (`llama-3.3-70b-versatile`) and pipes output through `glow` — it requires `$GROQ_API_KEY` to be set as a file path
- sketchybar lives under `home/desktop/sketchybar/` but is macOS-only; hyprland/niri are Linux-only
- `nix-switch` uses `hostname -s` at runtime — the hostname must match a key in `nixosConfigurations` / `darwinConfigurations`
