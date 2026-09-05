# nix-packages

A collection of reusable third-party Nix packages, split out from
[nix-config](https://github.com/Curious-r/nix-config).

## Architecture

```text
nix-packages
  reusable third-party packages

nix-config
  system/user configuration and local packages
```

This repository is npins-first: source pins live in [`npins/`](./npins) and are
owned here, not by the consumer. `flake.nix` is only a compatibility and
distribution boundary — the package API is plain Nix and evaluates without the
flake:

```text
npins
  ↓
package expressions (pkgs/)
  ↓
lib package set (lib/)
  ↓
├── overlay (overlays/)
└── flake packages (flake.nix)
```

## Packages

| Name | Source |
| ---- | ------ |
| `vaultix` | [Curious-r/vaultix](https://github.com/Curious-r/vaultix) (branch `merged-wip`) |
| `pam-fido-remote` | [r-vdp/pam-fido-remote](https://codeberg.org/r-vdp/pam-fido-remote) (releases) |

## Usage

### Pure Nix

`lib/default.nix` is the canonical package API. It takes a `pkgs` set and an
optional `sources` override, and returns an attribute set of packages:

```nix
import ./lib {
  pkgs = import <nixpkgs> { };
}
# => { vaultix = …; pam-fido-remote = …; }
```

There is no dependency on flake evaluation (`builtins.getFlake`), `self`, or
`inputs`.

### Flake

```console
$ nix build .#vaultix
$ nix build .#pam-fido-remote
```

### Overlay

```nix
nixpkgs.overlays = [ nixPackages.overlays.default ];
```

This makes both packages available as `pkgs.vaultix` and
`pkgs.pam-fido-remote`. The overlay is a convenience API on top of
`lib/default.nix`, not a second implementation.

## Updating pins

```console
$ npins update
```

If a source revision changes, update the corresponding `cargoDeps` hash in the
package expression (`pkgs/*/package.nix`) accordingly.
