---
title: "Claude Code thinking mode"
author: ["Yejun Su"]
date: 2025-12-15T12:27:00+08:00
tags: ["claude"]
draft: false
---

In recent versions, Claude Code has changed how thinking mode works compared to the version in [Claude Code in Action]({{< relref "20250720T140631--claude-code-in-action__claude_course.org" >}}).

From <https://github.com/anthropics/claude-code/issues/9072#issuecomment-3648376741>:

-   Only `ultrathink` is the special keyword that enables thinking on a per-request basis. Phrases like "think", "think hard", "think more" don't have any impact on the allocated thinking token budget.
-   If you need fine-grained control over the token budget (vs. just allocating all 31,999 tokens to the thinking budget), you can set the `MAX_THINKING_TOKENS` environment variable. This setting takes priority over `ultrathink`, so if you set a lower `MAX_THINKING_TOKENS` threshold, `ultrathink` doesn't override it.

From <https://code.claude.com/docs/en/common-workflows#use-extended-thinking-thinking-mode>:

-   Sonnet 4.5 and Opus 4.5 have thinking enabled by default. All other models have thinking disabled by default.
-   When thinking is enabled (via `/config` or `ultrathink`), Claude can use up to 31,999 tokens from your output budget for internal reasoning.
-   Note that `ultrathink` both allocates the thinking budget AND _semantically signals to Claude to reason more thoroughly_, which may result in deeper thinking than necessary for your task.
