---
title: "Emacs $PATH"
author: ["Yejun Su"]
date: 2025-09-08T22:29:00+08:00
tags: ["emacs"]
draft: false
---

The following configuration enables Emacs to inherit the correct `$PATH` from the shell in all cases:

-   `M-x describe-variable: exec-path`
-   `M-x eval-expression: (getenv "PATH")`
-   `M-x shell-command: echo $PATH`
-   `M-x compile: echo $PATH`

My shell is located at `/run/current-system/sw/bin/fish`, so the configuration is:

```emacs-lisp
(use-package exec-path-from-shell
  :pin nongnu
  :if (memq window-system '(mac ns x))
  :init
  (setq shell-file-name "/run/current-system/sw/bin/fish")
  :config
  (dolist (var '("__fish_nixos_env_preinit_sourced"
                 "__NIX_DARWIN_SET_ENVIRONMENT_DONE"
                 "__HM_SESS_VARS_SOURCED"))
    (add-to-list 'exec-path-from-shell-variables var))
  (exec-path-from-shell-initialize))

(use-package envrc
  :pin melpa
  :hook (after-init . envrc-global-mode))
```

-   `shell-file-name` specifies the shell for commands like `shell-command` and `start-process`, it uses your system's default shell by default.
-   `exec-path-from-shell-shell-name` specifies the shell that `exec-path-from-shell` uses to retrieve the `$PATH` environment variable, it falls back to `shell-file-name`.
-   `exec-path-from-shell-variables` is recommended to set if you use Direnv + HomeManager + Fish ([via](https://github.com/purcell/envrc/issues/92#issuecomment-2415612472)).
