---
title: "Create sourcehut paste in Emacs"
author: ["Yejun Su"]
date: 2023-09-05T00:27:00+08:00
tags: ["emacs", "sourcehut"]
draft: false
---

[Paste](https://paste.sr.ht) is a sourcehut service like GitHub's [Gist](https://gist.github.com). I wrote a function
utilizing [hut](https://git.sr.ht/~emersion/hut) to create a paste in Emacs:

```emacs-lisp
(defun yejun/paste-region-or-buffer (&optional p)
  (interactive "P")
  (let ((filename (read-string "Enter filename: " (buffer-name)))
        (output-buffer " *paste-output*")
        (public (if p " --visibility public" "")))
    (shell-command-on-region
     (if (use-region-p) (region-beginning) (point-min))
     (if (use-region-p) (region-end) (point-max))
     (concat "hut paste create --name \"" filename "\"" public)
     output-buffer)
    (with-current-buffer output-buffer
      (goto-char (point-max))
      (forward-line -1)
      (kill-new (thing-at-point 'line)))
    (kill-buffer output-buffer)))
```

When calling the function, you will be prompted for a filename, by default,
`buffer-name` is pre-filled for convenience. After creating the paste, the URL
is copied to the clipboard.

There are two advices on giving a filename:

-   Give a meaningful filename: currently you cannot search paste by content, so a
    meaningful filename makes search easier.
-   Give a filename extension for code highlighting: see [this paste](https://paste.sr.ht/~goofansu/bd594323cc0036d413ab5afb70f5d50a2b195d33) for details.

The default visiblity is `unlisted`, using `C-u` to create a `public` paste, for
Doom Emacs users, that's `SPC u`.
