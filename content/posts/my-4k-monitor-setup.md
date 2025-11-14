---
title: "My 4K monitor setup"
author: ["Yejun Su"]
date: 2025-11-12T17:17:00+08:00
lastmod: 2025-11-19T17:20:10+08:00
tags: ["hardware"]
draft: false
toc: false
---

I recently purchased an LG 27UP850K monitor with a 4K resolution (3840x2160). At its native resolution, everything is tiny. When scaled to the 1080p resolution (1920x1080), it displays the same content as a 1080p screen but with much sharper clarity. Then I scaled to the 2K resoluition (2560x1440), it warns "Using a scaled resolution may affect performance". I finally switched back to the native 4K resolution because it displays much more content, which was my main reason for buying this monitor.

I adjusted the settings for the [apps]({{< relref "tools" >}}) I use most often. Here's a summary:

-   Google Chrome: Settings -&gt; Appearance -&gt; Set "Page zoom" to 150%.
-   Slack: Preferences -&gt; Accessibility -&gt; Set "Zoom" to 150%.
-   Emacs: Create a "large" [fontaine](https://protesilaos.com/emacs/fontaine) preset.
    ```emacs-lisp
    (use-package fontaine
      :custom
      (fontaine-presets
       '((regular
          :default-height 160)
         (large
          :default-height 240)
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
-   Zed: Create a "large" [profile](https://zed.dev/docs/configuring-zed#profiles) and set up the font sizes.
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
-   Ghostty: By default, the new windows and tabs will [inherit the font size](https://ghostty.org/docs/config/reference#window-inherit-font-size) of the previously focused window. So I just set font size to 24px using a keybinding in any window, and create new windows and tabs from that.
    ```text
    keybind = ctrl+shift+l=set_font_size:24
    ```


## Update on 2025-11-15 {#update-on-2025-11-15}

I’ve been using the above settings for three days, and the biggest problem is the overall user interface appearing very small. I switched the display resolution to 2K scaling, and everything is readable now. The warning mentioned at the beginning is now a thing of the past, as explained in ["4K Scaling" Is Not a Problem on Modern Macs](https://bytecellar.com/2022/11/08/4k-scaling-is-not-a-problem-on-modern-macs/):

> The way around this is to have macOS “scale” the display to a more ideal lower resolution, but choosing that option in display preferences presents a warning: “Using a scaled resolution may affect performance.” What the OS does here is to scale up the chosen resolution to double height and double width (4x the pixels displayed) and then scale them back down to the display’s native resolution — 60 times per second. Indeed, this can be too much for certain older systems out there. But, as you will see, modern Macs should be able to handle the task just fine.


## Update on 2025-11-19 {#update-on-2025-11-19}

I found the text on the 4K monitor is really sharp, so that I could easily read 12pt font when scaled down to 1080p, whereas I previously needed 16pt on a regular 1080p monitor. So I configured editors and the terminal to use 12pt font, and set the Google Chrome's page zoom to 75% to read more content.
