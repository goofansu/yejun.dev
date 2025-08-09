---
title: "Install @anthropic-ai/claude-code using Nix npm"
author: ["Yejun Su"]
date: 2025-08-10T00:05:00+08:00
tags: ["nix", "npm"]
draft: false
---

I was installing `claude-code` via Nix, but new releases take 2-3 days to appear in the `nixpkgs-unstable` branch. I want to use `npm` directly instead. By default, `npm` installs global packages to the immutable Nix store, causing `npm install -g` fails.

Based on [this article](https://matthewrhone.dev/nixos-npm-globally), the solution is straightforward: configure `npm` to use a writable `prefix` directory. The required Nix configuration is ([commit](https://github.com/goofansu/nix-config/commit/8752b850d181783c7648b949737c3a4d155ccfd0)):

```nix
home.file = {
  ".npmrc".text = "prefix=~/.npm-global";
};

home.sessionPath = [
  "$HOME/.npm-global/bin"
];
```

Now I can install `claude-code` using `npm`:

```shell
npm install -g @anthropic-ai/claude-code
```

The version today is:

```shell
$ claude --version
1.0.72 (Claude Code)
```
