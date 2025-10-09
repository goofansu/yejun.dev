---
title: "Accept per-project flake config"
author: ["Yejun Su"]
date: 2025-10-08T23:05:00+08:00
tags: ["bib", "devenv", "nix"]
draft: false
---

A project using [devenv](https://devenv.sh) prompts: `do you want to allow configuration setting 'extra-substituters' to be set to 'https://devenv.cachix.org' (y/N)?.`, but I cannot input `y` in the stdin. It happens in fish shell, and there is an issue: <https://github.com/direnv/direnv/issues/1022>.

The solution is to set `accept-flake-config: true` in the global nix setting ([via](https://blog.ielliott.io/per-project-nix-substituters)):

```nix
{
  nix = {
    settings = {
      experimental-features = "nix-command flakes";
      accept-flake-config = true;
    };
  };
}
```
