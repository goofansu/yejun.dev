---
title: "Send Nix code from Emacs to Kitty"
author: ["Yejun Su"]
date: 2023-10-03T02:38:00+08:00
tags: ["emacs", "kitty", "nix"]
draft: false
---

I'm learning Nix by following [this tutorial](https://nix.dev/tutorials/first-steps/) and taking notes using Org
Mode. I organized the notes with my thoughts and some code examples. Doom Emacs
provides a function `+eval/send-region-to-repl` to run code in a language's REPL
buffer. It's useful until multiple-line input comes, which prints like so:

```shell { hl_lines=["9-15"] }
nix-repl> let
  first_name = "Yejun";
  last_name = "Su";
in
  {
    full_name = "${first_name} ${last_name}";
  }

let
            first_name = "Yejun";
            last_name = "Su";
          in
            {
              full_name = "${first_name} ${last_name}";
            }
{ full_name = "Yejun Su"; }
```

It appears that the input is also getting printed along with the result, which
isn't expected. However, when I tried with `nix repl` in Kitty, I didn't
encounter this problem. A viable solution that emerged is to send the Nix code
from the org-babel source block directly to the Nix REPL in Kitty.

Thanks to the [Kitty's remote control](https://sw.kovidgoyal.net/kitty/overview/#remote-control), it's easy to advise the
`+eval/send-region-to-repl` function to send the Nix code to Kitty:

```emacs-lisp
(defun kitty--ensure-nix-repl-tab ()
  (unless (zerop (shell-command "kitty @ ls | grep -q '\"title\": \"nix-repl\"'"))
    (shell-command "kitty @ launch --type tab --tab-title nix-repl nix repl")))

(defun kitty--send-region-to-nix-repl-tab ()
  (shell-command-on-region
   (if (use-region-p) (region-beginning) (point-min))
   (if (use-region-p) (region-end) (point-max))
   "kitty @ send-text --match-tab title:nix-repl --stdin"))

(defun org-babel-src-block-language-p (language)
  (let ((block-info (org-element-at-point)))
    (and (eq (car block-info) 'src-block)
         (string= language (org-element-property :language block-info)))))

(defadvice +eval/send-region-to-repl (around my-send-region-to-repl activate)
  (if (and (eq major-mode 'org-mode)
           (org-babel-src-block-language-p "nix"))
      (progn
        (kitty--ensure-nix-repl-tab)
        (kitty--send-region-to-nix-repl-tab))
    ad-do-it))
```

When calling the `+eval/send-region-to-repl` function (`SPC c s`), if current
major mode is `org-mode` and the language of the org-babel source block is
`nix`, it sends the selected code to Kitty's `nix-repl` tab, which runs the `nix
repl` so that the code is evaluated in the Nix REPL. The tab will be created if
not exist.

{{< figure src="/attachments/20250127T001947--kitty-nix-repl.gif" alt="Screencast of send nix code from Emacs to Kitty" >}}
