---
title: "Color discrepancy between the terminal and Zed's integrated terminal"
author: ["Yejun Su"]
date: 2026-04-24T22:06:00+08:00
tags: ["ghostty", "terminal", "zed"]
draft: false
---

When running the pi coding agent in Zed's integrated terminal, I found the appearance of the theme is not the same as in Ghostty.

The root cause is that, by default, Zed sets the [minimum contrast](https://zed.dev/docs/reference/all-settings#terminal-minimum-contrast) to 45 between foreground and background colors in the terminal. Set this to 0 to disable this feature:

```json
{
  "terminal": {
    "minimum_contrast": 0
  }
}
```
