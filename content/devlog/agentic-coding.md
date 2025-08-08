---
title: "Agentic coding"
author: ["Yejun Su"]
date: 2025-07-26T11:05:00+08:00
tags: ["ai"]
draft: false
---

My workflow is based on [devenv](https://devenv.sh/) and [git worktree](https://docs.anthropic.com/en/docs/claude-code/common-workflows#run-parallel-claude-code-sessions-with-git-worktrees). In this post, I'll use a Rails application as an example.


## Context engineering {#context-engineering}


### Project context {#project-context}

```shell
cd my_app
git worktree add -b <branch> ../my_app-feature-a develop
cd ../my_app-feature-a
direnv allow
dev
```

In this way, it's easy to develop across multiple branches while preserving context for code agents.


### Log context {#log-context}

Always truncate the `development.log` file[^fn:1] when starting the server to ensure agents have a clear and relevant log context.


### `bin/dev` {#bin-dev}

```shell
#!/usr/bin/env sh

truncate -s 0 log/development.log
exec bundle exec foreman start -f Procfile.dev "$@"
```


### `Procfile.dev` {#procfile-dot-dev}

```yaml
web: bundle exec rails s -p 3000
js: bundle exec webpacker-dev-server
```

[^fn:1]: Inspired by [Agentic Coding with Claude Code](https://www.youtube.com/live/Y4_YYrIKLac)
