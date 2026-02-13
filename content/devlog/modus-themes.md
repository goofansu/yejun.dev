---
title: "Modus themes"
author: ["Yejun Su"]
date: 2026-02-13T11:19:00+08:00
lastmod: 2026-02-14T00:21:48+08:00
tags: ["colors"]
draft: false
toc: false
state: "evergreen"
---

The Modus themes is created by [Prot](https://protesilaos.com/). I love its aesthetic and use it almost everywhere.


## Emacs {#emacs}

The original [modus-themes](https://protesilaos.com/emacs/modus-themes) package.


## Zed {#zed}

The [modus-themes](https://zed.dev/extensions/modus-themes) extension created by [Vitaly Slobodin](https://bsky.app/profile/did:plc:5rc3vpldcyehjjqkj2qmdwvo).


## Ghostty {#ghostty}

The config is transformed from the [DIY Range of color with terminal emulators](https://protesilaos.com/emacs/modus-themes#h:6b8211b0-d11b-4c00-9543-4685ec3b742f) section.

```cfg
background = #000000
foreground = #ffffff
palette = 0=#000000
palette = 1=#ff8059
palette = 2=#44bc44
palette = 3=#d0bc00
palette = 4=#2fafff
palette = 5=#feacd0
palette = 6=#00d3d0
palette = 7=#bfbfbf
palette = 8=#595959
palette = 9=#ef8b50
palette = 10=#70b900
palette = 11=#c0c530
palette = 12=#79a8ff
palette = 13=#b6a0ff
palette = 14=#6ae4b9
palette = 15=#ffffff
```

Here's the Nix configuration using home-manager:

```nix
programs.ghostty = {
  # ...
  themes = {
    modus-vivendi = {
      background = "#000000";
      foreground = "#ffffff";
      palette = [
        "0=#000000"
        "1=#ff8059"
        "2=#44bc44"
        "3=#d0bc00"
        "4=#2fafff"
        "5=#feacd0"
        "6=#00d3d0"
        "7=#bfbfbf"
        "8=#595959"
        "9=#ef8b50"
        "10=#70b900"
        "11=#c0c530"
        "12=#79a8ff"
        "13=#b6a0ff"
        "14=#6ae4b9"
        "15=#ffffff"
      ];
    };
  };
};
```


## This website {#this-website}

I created the [hugo-modus](https://github.com/goofansu/hugo-modus) theme for this blog.
