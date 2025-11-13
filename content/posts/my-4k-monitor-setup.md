---
title: "My 4K monitor setup"
author: ["Yejun Su"]
date: 2025-11-12T17:17:00+08:00
lastmod: 2025-11-13T09:54:21+08:00
tags: ["hardware"]
draft: false
toc: false
---

I recently purchased an LG 27UP850K monitor with a 4K resolution (3840x2160). At its native resolution, everything is tiny. When scaled to the 1080p resolution (1920x1080), it displays the same content as a 1080p screen but with much sharper clarity. Then I scaled to the 2K resoluition (2560x1440), it warns "Using a scaled resolution may affect performance". I finally switched back to the native 4K resolution because it displays much more content, which was my main reason for buying this monitor.

I adjusted the settings for the [apps]({{< relref "tools" >}}) I use most often. Here's a summary:

-   Google Chrome: Settings -&gt; Appearance -&gt; Set "Page zoom" to 125%.
-   Slack: Preferences -&gt; Accessibility -&gt; Set "Zoom" to 125%.
-   Emacs: Create a "large" [fontaine](https://protesilaos.com/emacs/fontaine) preset.[^fn:1]
    ```emacs-lisp
    (use-package fontaine
      :custom
      (fontaine-presets
       '((regular
          :default-height 160)
         (large
          :default-height 240)
         (presentation
          :default-family "Aporetic Serif Mono"
          :default-height 360
          :fixed-pitch-family "Aporetic Serif Mono"
          :variable-pitch-family "Aporetic Sans")
         (t
          :default-family "Aporetic Sans Mono"
          :default-weight regular
          :default-slant normal
          :default-width normal
          :default-height 100
          :fixed-pitch-family "Aporetic Sans Mono"
          :variable-pitch-family "Aporetic Serif")
         ))
      :config
      (fontaine-set-preset (or (fontaine-restore-latest-preset) 'regular)))
    ```
-   Zed: Create a "large" [profile](https://zed.dev/docs/configuring-zed#profiles) and set up the font sizes.[^fn:2]
    ```json
    {
      "profiles": {
        "large": {
          "ui_font_size": 24,
          "buffer_font_size": 24,
          "agent_buffer_font_size": 24
        }
      }
    }
    ```
-   Ghostty: By default, the new windows and tabs will [inherit the font size](https://ghostty.org/docs/config/reference#window-inherit-font-size) of the previously focused window. So I just set font size to 24px using a keybinding[^fn:3] in any window, and create new windows and tabs from that.
    ```text
    keybind = ctrl+shift+l=set_font_size:24
    ```

[^fn:1]: [Emacs config](https://github.com/goofansu/emacs-config/blob/7f10543b3224e9ff75c9863cfc4d6db9e1305e1a/modules/init-ui.el#L25-L51%20)
[^fn:2]: [Zed config](https://github.com/goofansu/zed-config/blob/3cf923ed2c228b391ae853502ea3e20096984ea4/settings.json#L57-L70)
[^fn:3]: [Ghostty config](https://github.com/goofansu/nix-config/blob/96c5958ccd7bc5fcd5bb167cdabd8049ebbecee3/term.nix#L55-L58)
