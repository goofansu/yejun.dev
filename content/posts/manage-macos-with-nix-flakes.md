---
title: "Manage macOS with Nix flakes"
author: ["Yejun Su"]
date: 2023-10-19T11:10:00+08:00
tags: ["macos", "nix"]
draft: true
toc: true
---

## Nix flakes {#nix-flakes}

> A flake is a directory that contains a file named `flake.nix` in the root
> directory. `flake.nix` specifies some metadata about the flake such as
> dependencies (called _inputs_), as well as its /outputs (the Nix values such as
> packages or NixOS modules provided by the flake).
>
> To ensure reproducibility, Nix will automatically generate and use a lock file
> called flake.lock in the flake's directory. The lock file contains a graph
> structure isomorphic to the graph of dependencies of the root flake.
>
> -- [RFC 0049: Flakes](https://github.com/tweag/rfcs/blob/flakes/rfcs/0049-flakes.md#flakes)

According to the definition, a flake has two files:

```text
.
├── flake.lock
└── flake.nix
```

The `flake.nix` has these attributes:

-   `description`: what is the flake for?
-   `inputs`: an attribute set specifying the dependencies of the flake.
-   `outputs`: a function which accepts `self`[^fn:1] and attributes of `inputs` as
    its params, and returns the Nix values as its results.

A basic `flake.nix` is as simple as the following:

```nix
{
  description = "A basic flake";
  inputs = { };
  outputs = { self }: { };
}
```


### Example {#example}

Let's create a `flake-example` directory for the `flake.nix`, thus, the
`flake-example` is called a flake. Run `nix build` in the flake for the first
time:

```text
$ nix build
error: flake 'path:/tmp/flake-example' does not provide attribute 'packages.aarch64-darwin.default' or 'defaultPackage.aarch64-darwin'
```

The error means something is missing in the `outputs`, let's set the result to
`self` for a quick experiment:

```nix { hl_lines=["5-9"] }
{
  description = "A basic flake";
  inputs = { };
  outputs = { self }:
    let
      system = "aarch64-darwin";
    in {
      packages.${system}.default = self;
    };
}
```

Run `nix build` again:

```text
$ nix build
error: flake output attribute 'packages.aarch64-darwin.default' is not a derivation or path
```

The flake output attribute `packages.aarch64-darwin.default` should be a
derivation or path[^fn:2]. Derivation is an important concept in Nix, but to keep
things simple, let's put it aside and set the output attribute to a Nix path:

```nix { hl_lines=["8"] }
{
  description = "A basic flake";
  inputs = { };
  outputs = { self }:
    let
      system = "aarch64-darwin";
    in {
      packages.${system}.default = ./.;
    };
}
```

`./.` denotes the current directory, similarly, `./flake.nix` denotes the
`flake.nix` file in the current directory.

Run `nix build` and it is successful:

```text
$ tree
.
├── flake.lock
├── flake.nix
└── result -> /nix/store/rl108r5a3nwxyciwj0ibgdi3d55m1rxx-source
```

The `result` symbolic link is the output of the build result, which is located
in the `/nix/store` directory.

```bash
$ tree result
result
├── flake.lock
└── flake.nix
```

You can see the `result` directory has the same files as the `flake-example`
directory. So our first flake is done, it makes a copy of current directory as
`outputs`.

[^fn:1]: `self` refers to the outputs and source tree of a flake.
[^fn:2]: An absolute `path` starts with `/`, while a relative `path` usually
    starts with `.`, and `./.` denotes the current directory.
