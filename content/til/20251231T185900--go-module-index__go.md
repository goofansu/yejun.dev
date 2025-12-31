---
title: "Go module index"
author: ["Yejun Su"]
date: 2025-12-31T18:59:00+08:00
tags: ["go"]
draft: false
---

I self-hosted Miniflux and want to create new feed through command line, so I vibe coded a Go project.

After pushing to GitHub, `go install` keeps failing:

```shell
$ go install github.com/goofansu/miniflux-cli/cmd/miniflux-cli@latest

go: downloading github.com/goofansu/miniflux-cli v0.0.0-20251231103549-8410b6d43c7b
go: github.com/goofansu/miniflux-cli/cmd/miniflux-cli@latest: github.com/goofansu/miniflux-cli@v0.0.0-20251231103549-8410b6d43c7b: verifying module: github.com/goofansu/miniflux-cli@v0.0.0-20251231103549-8410b6d43c7b: reading https://sum.golang.org/lookup/github.com/goofansu/miniflux-cli@v0.0.0-20251231103549-8410b6d43c7b: 404 Not Found
        server response:
        not found: github.com/goofansu/miniflux-cli@v0.0.0-20251231103549-8410b6d43c7b: invalid version: git ls-remote -q https://github.com/goofansu/miniflux-cli in /tmp/gopath/pkg/mod/cache/vcs/abd71c376a041e3c0a394d0d34d9b24cedb4a6426ec6abe8ef063bde71093ddd: exit status 128:
                fatal: could not read Username for 'https://github.com': terminal prompts disabled
        Confirm the import path was entered correctly.
        If this is a private repository, see https://golang.org/doc/faq#git_https for additional information.
```

The solution is to visit <https://proxy.golang.org/github.com/goofansu/miniflux-cli/@latest>, and then the URL works: <https://sum.golang.org/lookup/github.com/goofansu/miniflux-cli@v0.0.0-20251231103549-8410b6d43c7b>.

Reference: <https://proxy.golang.org/>
