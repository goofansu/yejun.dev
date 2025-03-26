---
title: "Emacs: make ‘save-some-buffers’ show diff on demand"
author: ["Yejun Su"]
date: 2025-03-14T09:42:00+08:00
tags: ["emacs"]
draft: false
---

[Emacs: make ‘save-some-buffers’ show diff on demand](https://protesilaos.com/codelog/2024-12-11-emacs-diff-save-some-buffers/)

> The command `save-some-buffers`, which is bound to `C-x s` by default is helpful when you need to save lots of buffers efficiently. Instead of figuring out which ones are modified and visiting each of them to decide what to do, you invoke `save-some-buffers`. It prompts for an action, one buffer at a time.
>
> -- Prot

I just know from Prot that it is the `save-some-buffers` command that ask me to save changes when doing operations such as `magit-status`. It prompts whether each buffer should be saved and provides the corresponding actions. I didn't notice there is a `d` action to display the difference between the buffer and its target file, which is very handy as sometimes I don't remember what I've changed so far.
