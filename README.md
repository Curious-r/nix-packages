# nix-packages

A collection of reusable third-party Nix packages, split out from [nix-config](https://github.com/Curious-r/nix-config).

## Architecture

```text
nix-packages
  reusable package scope

nix-config
  system/user configuration and integration
```

The two repositories have different ownership boundaries:

- `nix-packages` owns reusable package definitions and their package-local update logic.
- `nix-config` owns system configuration, Home Manager/NixOS modules, and configuration-specific source pins.
- Package definitions in this repository are self-contained and do not depend on the repository's flake interface or a global source registry.

This repository follows a Nix-first design inspired by the nixpkgs package collection model. The package tree and `default.nix` form the canonical package interface; the flake is an optional compatibility and distribution layer.

The package collection is implemented as a small nixpkgs-style package scope. `default.nix` builds that scope with `lib.makeScope`, allowing packages in this repository to reference one another through `callPackage` while continuing to use the underlying nixpkgs package set for external dependencies.

The canonical package tree is name-based:

```text
pkgs/
└── by-name/
    ├── da/
    │   └── daed/
    │       ├── package.nix
    │       └── update.sh
    ├── pa/
    │   └── pam-fido-remote/
    │       └── package.nix
    ├── va/
    │   └── vaultix/
    │       └── package.nix
    └── ze/
        ├── zen-browser/
        │   └── package.nix
        └── zen-browser-unwrapped/
            ├── package.nix
            └── update.sh
```

Package discovery is automatic. Adding a package to `pkgs/by-name` makes it available through the repository's package scope without maintaining a separate package list.

```text
pkgs/by-name/
      ↓
pkgs/by-name.nix
      ↓
  default.nix
      │
      │ lib.makeScope
      ↓
 package scope
      │
      ├──→ package definitions
      │       ├──→ nix-build
      │       └──→ package updater
      │
      ├──→ overlay.nix
      │       ↓
      │   pkgs.curious.<name>
      │
      └──→ flake.nix
              ↓
         packages.<system>.<name>
```

The scope contains both packages and the scope helpers provided by `lib.makeScope`. When a pure package attribute set is required, such as for flake `packages` outputs or repository tooling, it is obtained from the scope's `packages` function.

`flake.nix` is an optional compatibility and distribution layer. Package definitions themselves do not depend on it.

## Packages

| Name                    | Source                                                                                         |
| ----------------------- | ---------------------------------------------------------------------------------------------- |
| `vaultix`               | [milieuim/vaultix](https://github.com/milieuim/vaultix), upstream `main`, pinned revision      |
| `pam-fido-remote`       | [r-vdp/pam-fido-remote](https://codeberg.org/r-vdp/pam-fido-remote), release, init at `v0.1.5` |
| `daed`                  | [daeuniverse/daed](https://github.com/daeuniverse/daed), release, init at `v2.1.1`             |
| `zen-browser`           | [zen-browser/desktop](https://github.com/zen-browser/desktop), release, init at `v1.22.3b`     |
| `zen-browser-unwrapped` | [zen-browser/desktop](https://github.com/zen-browser/desktop), release, init at `v1.22.3b`     |

`zen-browser` is the default `wrapFirefox`-based package, while `zen-browser-unwrapped` exposes the reusable unwrapped browser derivation for custom wrappers.

## Usage

### Package scope

The canonical Nix interface is `default.nix`. It returns a package scope based on the provided nixpkgs package set.

From the repository root:

```bash
nix-build -A vaultix
nix-build -A pam-fido-remote
nix-build -A daed
nix-build -A zen-browser
nix-build -A zen-browser-unwrapped
```

The scope can also be imported directly:

```nix
let
  curious = import ./default.nix {
    pkgs = import <nixpkgs> { };
  };
in
curious.zen-browser
```

Packages within the scope can depend on one another using normal `callPackage` arguments. For example, `zen-browser` is implemented by wrapping `zen-browser-unwrapped`.

### Overlay

The canonical integration API for adding the package scope to an existing nixpkgs package set is the overlay:

```nix
nixpkgs.overlays = [
  inputs.curious.overlays.default
];
```

The scope is then available under `pkgs.curious`:

```nix
pkgs.curious.vaultix
pkgs.curious.pam-fido-remote
pkgs.curious.daed
pkgs.curious.zen-browser
pkgs.curious.zen-browser-unwrapped
```

`pkgs.curious` is a package scope. In addition to its packages, it provides the scope helpers supplied by `lib.makeScope`, such as `callPackage` and `overrideScope`.

The scope is built on the final nixpkgs package set supplied to the overlay, so package definitions can use both the repository's packages and the surrounding nixpkgs packages.

### Flake

The repository also exposes its packages through its flake interface:

```bash
nix build .#vaultix
nix build .#pam-fido-remote
nix build .#daed
nix build .#zen-browser
nix build .#zen-browser-unwrapped
```

For a flake consumer:

```nix
{
  inputs.curious.url = "github:Curious-r/nix-packages";

  # ...

  environment.systemPackages = [
    inputs.curious.packages.${system}.vaultix
  ];
}
```

The `curious` input name is a consumer-side convention; the repository's flake package outputs remain `packages.<system>.<name>`.

The flake exposes the derivation-only package view of the package scope. Package definitions do not rely on the flake interface.

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

Packages in the scope may also depend on other packages from this repository by declaring them as normal `callPackage` arguments.

The package expression should be self-contained and should not depend on files outside its own package directory.

Once added, the package is automatically exposed through:

- the package scope as `foo`;
- the overlay as `pkgs.curious.foo`;
- the flake as `packages.<system>.foo`;
- the CI build matrix.

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

The updater resolves packages from the package scope's derivation-only package view and executes the selected package's `passthru.updateScript`.

The package update workflow runs these updates automatically and opens or updates an automated pull request.

## Pinned source updates

The repository pins `nixpkgs` through [npins](https://github.com/andir/npins) for CI cache alignment and local tooling evaluation, independently of package sources.

The `npins` update workflow periodically updates pinned sources and opens a pull request. Package source updates and pinned source updates therefore remain independent:

```text
package updater
  → package.nix

npins updater
  → npins/sources.json
```

Both changes are validated by the normal CI pipeline.

## Development

The repository provides a development environment through [devenv](https://devenv.sh/).

Formatting can be checked with:

```bash
nix fmt
```

The flake can be checked with:

```bash
nix flake check --all-systems
```

Packages can be built locally through the canonical package scope with:

```bash
nix-build -A vaultix
nix-build -A pam-fido-remote
nix-build -A daed
nix-build -A zen-browser
nix-build -A zen-browser-unwrapped
```
