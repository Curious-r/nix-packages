# nix-packages

A collection of reusable third-party Nix packages, split out from
[nix-config](https://github.com/Curious-r/nix-config).

## Architecture

```text
nix-packages
  reusable package collection

nix-config
  system/user configuration and integration
```

The two repositories have different ownership boundaries:

* `nix-packages` owns reusable package definitions.
* `nix-config` owns system configuration, Home Manager/NixOS modules,
  and configuration-specific source pins.
* Package definitions in this repository are self-contained and do not
  depend on the repository's flake interface or a global source registry.

The canonical package tree is name-based:

```text
pkgs/
└── by-name/
    ├── pa/
    │   └── pam-fido-remote/
    │       └── package.nix
    └── va/
        └── vaultix/
            └── package.nix
```

Package discovery is automatic. Adding a package to `pkgs/by-name` makes it
available through the repository's package interfaces without maintaining a
separate package list.

```text
pkgs/by-name/
      ↓
pkgs/by-name.nix
      ├──→ overlay.nix
      │       ↓
      │    pkgs.<name>
      │
      ├──→ flake.nix
      │       ↓
      │    packages.<system>.<name>
      │
      └──→ CI
              ↓
          build matrix
```

`flake.nix` is an optional compatibility and distribution layer. The package
definitions themselves do not depend on the flake interface.

## Packages

| Name              | Source                                                                                     |
| ----------------- | ------------------------------------------------------------------------------------------ |
| `vaultix`         | [milieuim/vaultix](https://github.com/milieuim/vaultix) (upstream `main`, pinned revision) |
| `pam-fido-remote` | [r-vdp/pam-fido-remote](https://codeberg.org/r-vdp/pam-fido-remote) (release `v0.1.5`)     |

## Usage

### Overlay

The canonical public integration API is the overlay:

```nix
nixpkgs.overlays = [
  inputs.nix-packages.overlays.default
];
```

Packages can then be used as:

```nix
pkgs.vaultix
pkgs.pam-fido-remote
```

The overlay discovers packages directly from `pkgs/by-name`.

### Flake

The repository also exposes packages through its flake interface:

```console
$ nix build .#vaultix
$ nix build .#pam-fido-remote
```

For a flake consumer:

```nix
{
  inputs.nix-packages.url = "github:Curious-r/nix-packages";

  # ...

  environment.systemPackages = [
    inputs.nix-packages.packages.${system}.vaultix
  ];
}
```

The flake interface is provided for compatibility and distribution. Package
definitions do not rely on it.

## Adding a package

Create a directory using the first two lowercase letters of the package
attribute name:

```text
pkgs/by-name/<shard>/<name>/package.nix
```

For example:

```text
pkgs/by-name/fo/foo/package.nix
```

A package definition is a normal `callPackage`-style function:

```nix
{
  lib,
  stdenv,
  fetchFromGitHub,
}:

stdenv.mkDerivation {
  pname = "foo";
  version = "1.0.0";

  # ...
}
```

The package expression should be self-contained and should not depend on
files outside its own package directory.

Once added, the package is automatically exposed through:

* the overlay as `pkgs.foo`;
* the flake as `packages.<system>.foo`;
* the CI build matrix.

No package list needs to be updated manually.

## Development

The repository provides a development environment through
[`devenv`](https://devenv.sh/).

Formatting can be checked with:

```console
$ nix fmt -- --check $(git ls-files '*.nix')
```

The flake can be checked with:

```console
$ nix flake check --all-systems
```

Packages can be built locally with:

```console
$ nix build .#vaultix
$ nix build .#pam-fido-remote
```
