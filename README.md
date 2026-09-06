# nix-packages

A collection of reusable third-party Nix packages, split out from [nix-config](https://github.com/Curious-r/nix-config).

## Architecture

```text
nix-packages
  reusable package collection

nix-config
  system/user configuration and integration
````

The two repositories have different ownership boundaries:

* `nix-packages` owns reusable package definitions.
* `nix-config` owns system configuration, Home Manager/NixOS modules, and configuration-specific source pins.
* Package definitions in this repository are self-contained and do not depend on the repository's flake interface or a global source registry.

This repository follows a Nix-first design inspired by the traditional nixpkgs package collection model. The package tree and `default.nix` form the canonical package interface; the flake is an optional compatibility and distribution layer.

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

Package discovery is automatic. Adding a package to `pkgs/by-name` makes it available through the repository's package interfaces without maintaining a separate package list.

```text
pkgs/by-name/
      ↓
pkgs/by-name.nix
      │
      ├──→ default.nix
      │       ↓
      │   package set
      │       ├──→ nix-build
      │       └──→ package updater
      │
      ├──→ overlay.nix
      │       ↓
      │    pkgs.<name>
      │
      └──→ flake.nix
              ↓
         packages.<system>.<name>
```

`flake.nix` is an optional compatibility and distribution layer. Package definitions themselves do not depend on it.

## Packages

| Name              | Source                                                                                    |
| ----------------- | ----------------------------------------------------------------------------------------- |
| `vaultix`         | [milieuim/vaultix](https://github.com/milieuim/vaultix), upstream `main`, pinned revision |
| `pam-fido-remote` | [r-vdp/pam-fido-remote](https://codeberg.org/r-vdp/pam-fido-remote), release `v0.1.5`     |

## Usage

### Traditional package set

The canonical package interface is `default.nix`.

```bash
nix-build -A vaultix
nix-build -A pam-fido-remote
```

This exposes the same packages as the repository's other integration layers.

### Overlay

The canonical integration API for adding these packages to an existing nixpkgs package set is the overlay:

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

```bash
nix build .#vaultix
nix build .#pam-fido-remote
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

The flake interface is provided for compatibility and distribution. Package definitions do not rely on it.

## Adding a package

Create a directory using the first two lowercase letters of the package attribute name:

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

The package expression should be self-contained and should not depend on files outside its own package directory.

Once added, the package is automatically exposed through:

* the package set as `foo`;
* the overlay as `pkgs.foo`;
* the flake as `packages.<system>.foo`;
* the CI build matrix.

No package list needs to be updated manually.

## Package updates

Packages can declare their own update strategy through `passthru.updateScript`.

For example:

```nix
passthru.updateScript = nix-update-script { };
```

or, for an unstable branch-tracking package:

```nix
passthru.updateScript = nix-update-script {
  extraArgs = [ "--version=branch" ];
};
```

The repository-level updater is:

```text
tools/updater.nix
```

A package can be updated locally with:

```bash
nix-shell tools/updater.nix --argstr package <name>
```

The package update workflow runs these updates automatically and opens or updates an automated pull request.

## Flake input updates

Flake inputs are maintained separately from package sources.

The `flake.lock` update workflow periodically updates flake inputs and opens an automated pull request. Package source updates and flake input updates therefore remain independent:

```text
package updater
  → package.nix

flake input updater
  → flake.lock
```

Both changes are validated by the normal CI pipeline.

## Development

The repository provides a development environment through [devenv](https://devenv.sh/).

Formatting can be checked with:

```bash
nix fmt -- --check $(git ls-files '*.nix')
```

The flake can be checked with:

```bash
nix flake check --all-systems
```

Packages can be built locally through the canonical package set with:

```bash
nix-build -A vaultix
nix-build -A pam-fido-remote
```
