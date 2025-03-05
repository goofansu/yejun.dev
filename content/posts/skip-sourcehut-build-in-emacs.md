---
title: "Skip sourcehut build in Emacs"
author: ["Yejun Su"]
date: 2023-09-05T10:23:00+08:00
tags: ["emacs", "sourcehut"]
draft: false
---

[builds.sr.ht](https://builds.sr.ht/) is the GitHub Actions counterpart in sourcehut, it can run
jobs when you push to a git repository that contains a `build.yml` file.
According to the [manual](https://man.sr.ht/git.sr.ht/#push-options), you can skip submitting a build by using `git
push -o skip-ci`.

In Emacs, you can achieve this by [adding an infix argument](https://magit.vc/manual/transient/Modifying-Existing-Transients.html):

```emacs-lisp
(transient-append-suffix 'magit-push "-n"
  '("-s" "Skip CI" "--push-option=skip-ci"))
```

This inserts a new infix argument to toggle the `--push-option=skip-ci` argument
after the infix argument that toggles `--dry-run` in `magit-push`.

However, it is strange that neither argument `-o skip-ci` nor `-o=skip-ci` will
take effect:

```emacs-lisp
(transient-append-suffix 'magit-push "-n"
  '("-s" "Skip CI" "-o=skip-ci"))

(transient-append-suffix 'magit-push "-n"
  '("-s" "Skip CI" "-o skip-ci"))
```
