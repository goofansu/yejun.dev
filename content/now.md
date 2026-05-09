---
title: "What I'm doing now"
author: ["Yejun Su"]
date: 2025-07-31T11:38:00+08:00
lastmod: 2026-05-09T23:57:36+08:00
tags: ["personal"]
draft: false
---

(This page records my recent status. It's [inspired]({{< relref "inspired" >}}) by [Derek Sivers](https://sive.rs/now).)


## Delegate work to agents {#delegate-work-to-agents}

The [Tmux comes to the next Omarchy](https://www.youtube.com/watch?v=jqDZy2zaxcE) changed my workflow in the past month, I'm using tmux/worktrunk/pi/claude to work with agents. My tmux config is based on the [omarchy config](https://github.com/basecamp/omarchy/blob/dev/default/bash/fns/tmux). I added three bindings:

1.  Pick any worktree to open in new window
2.  Pick any visited directory to open in new session
3.  Pick a pane to jump in

Also, some agent workflows are easy to implement:

```shell
# bug fix
tmux new-window 'wt switch -c bug-fix -x pi -- "according to <jira_url>, find the root cause, and fix the bug"'

# pr review
tmux new-window 'wt switch pr:<pr_number> -x claude -- "/review <pr_number>"'
```


## Pi coding agent {#pi-coding-agent}

I use the [pi coding agent](https://github.com/badlogic/pi-mono/tree/main/packages/coding-agent) for agentic coding on my machine and have been exploring more use cases:

1.  [pi-chat](https://github.com/goofansu/pi-chat): delegate the support work to pi
2.  [pi-remote-control](https://github.com/goofansu/pi-remote-control): access pi sessions through a private network
3.  [pi-subagent](https://github.com/goofansu/pi-subagent): building the subagent tool to learn pi extension's lifecycle
