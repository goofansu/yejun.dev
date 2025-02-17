---
title: "Static website with Hugo and Nix"
author: ["Yejun Su"]
date: 2023-10-07T10:47:00+08:00
tags: ["hugo", "nix"]
draft: false
---

This website is built with Hugo, a static site generator, and built with
Nix[^fn:1]. This approach ensures the build won't break in the future because the
content, generator and builder are all unchanged.


## The configuration {#the-configuration}

Nix flakes is still an experimental feature but has been available for a long
time.

> A flake is simply a source tree (such as a Git repository) containing a file
> named `flake.nix` that provides a standardized interface to Nix artifacts such as
> packages or NixOS modules. Flakes can have dependencies on other flakes, with a
> “lock file” pinning those dependencies to exact revisions to ensure reproducible
> evaluation.
>
> -- <https://www.tweag.io/blog/2020-05-25-flakes/>

Here is the `flake.nix` of this website:

```nix { hl_lines=["10-15","18"] }
{
  description = "My personal website";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.05";
  inputs.flake-utils.url = "github:numtide/flake-utils";

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let pkgs = nixpkgs.legacyPackages.${system};
      in {
        packages.website = pkgs.stdenv.mkDerivation {
          name = "blog";
          src = self;
          buildPhase = "${pkgs.hugo}/bin/hugo";
          installPhase = "cp -r public $out";
        };

        defaultPackage = self.packages.${system}.website;
        devShells.default = pkgs.mkShell { packages = [ pkgs.hugo ]; };
      });
}
```

Everytime I clone the repo, there are two options:

-   run `nix develop` to enter a pure environment with the `hugo` program.
-   run `nix build` to get the static website in the `./result` directory.

It eliminates the need to worry about the development will be broken in the
future.


## Auto deployment {#auto-deployment}

I use sourcehut to host my website. When I pushed to the git repository, it will
be deployed automatically using the [sourcehut build service](https://builds.sr.ht/~goofansu/yejun.dev/commits/main/.build.yml). In the build, `nix
build` uses `flake.nix` to create exactly same environment as in development:

```yaml { hl_lines=["6","11"] }
image: nixos/latest
oauth: pages.sr.ht/PAGES:RW
packages:
- nixos.hut
environment:
  NIX_CONFIG: experimental-features = nix-command flakes
  site: yejun.dev
tasks:
- package: |
    cd $site
    nix build
    tar -C result -cvz . > ../site.tar.gz
- upload: |
    hut pages publish -d $site site.tar.gz
```

[^fn:1]: [Nix](https://nixos.org) is a tool focused on reproducible package management and system configuration.
