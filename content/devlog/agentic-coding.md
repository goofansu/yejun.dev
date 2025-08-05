---
title: "Agentic coding"
author: ["Yejun Su"]
date: 2025-07-26T11:05:00+08:00
tags: ["ai"]
draft: false
---

## Workflow {#workflow}

My workflow is based on [devenv](https://devenv.sh/) and [git worktree](https://docs.anthropic.com/en/docs/claude-code/common-workflows#run-parallel-claude-code-sessions-with-git-worktrees).

Use a Rails application for example:

```shell
cd my_app
git worktree add -b <branch> ../my_app-feature-a develop
cd ../my_app-feature-a
direnv allow
dev
```

In this way, it's easy to develop across multiple branches while preserving context for code agents.
