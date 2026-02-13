---
title: "Agentic coding"
author: ["Yejun Su"]
date: 2025-07-26T11:05:00+08:00
lastmod: 2026-02-07T11:07:48+08:00
tags: ["ai"]
draft: false
toc: true
state: "seedling"
---

My workflow is based on [devenv](https://devenv.sh/) and [git worktree](https://docs.anthropic.com/en/docs/claude-code/common-workflows#run-parallel-claude-code-sessions-with-git-worktrees). In this post, I'll use a Rails application as an example.


## Context engineering {#context-engineering}


### Project context {#project-context}

I maintain project context using git worktree. In this way, it's easy to develop across multiple branches while preserving context for code agents.

```shell
cd my_app
git worktree add ../my_app-feature-xyz -b feature/xyz develop
cd ../my_app-feature-xyz
direnv allow
bin/dev
```

Tip: A fish-shell alias for quickly switching between git worktree directories:

```shell
function gcd --description 'Fuzzy find and cd the selected git worktree'
    git worktree list --porcelain | grep '^worktree ' | sed 's/^worktree //' | fzf | awk '{print $1}' | read -l result; and cd $result
end
```


### Log context {#log-context}


#### Truncate log {#truncate-log}

Always truncate the `development.log` file[^fn:1] when starting the server to ensure agents have a clear and relevant log context.

```shell { hl_lines=["3"] }
#!/usr/bin/env sh

truncate -s 0 log/development.log
exec bundle exec foreman start -f Procfile.dev "$@"
```


### Browser context {#browser-context}

Providing agents with direct browser access would be extremely beneficial, as they can debug web pages by looking into console logs. Install `playwright` or `chrome-devtools` and ask agents to use it, your agent would appreciate it.

```shell
claude mcp add playwright npx @playwright/mcp@latest
claude mcp add chrome-devtools npx chrome-devtools-mcp@latest # require Node >= 22.12.0
```

And run in dangerous mode:

```json
claude --dangerously-skip-permissions
```

Example:

```text
> Use playwright to check http://localhost:3000, I'll sign in the account for you.

⏺ Perfect! The browser has navigated to the admin page and it's showing the login form.

  The page is ready for you to sign in. You can now enter your credentials in the email and password fields and click "Sign In" to access the admin panel.

> I've signed in, debugging the problem.

...omitted...

🎯 Mission Accomplished!

  Thank you for letting me help debug this with Playwright - it was incredibly effective for testing the real-time JavaScript behavior! 🚀
```


## Code review {#code-review}

I use the Zed editor to review the code changed by agents as it supports [multibuffers](https://zed.dev/docs/multibuffers) which allows me to edit the `git diff` results. Additionally, it's really fast and I enjoy using it in daily work.

Since I use Emacs as my main editor, switching between Zed and Emacs is necessary, it requires a single piece of code:

-   Emacs: <https://github.com/goofansu/emacs-config/blob/main/site-lisp/macos.el>
-   Zed: <https://github.com/goofansu/zed-config/blob/main/tasks.json> and <https://github.com/goofansu/zed-config/blob/main/keymap.json>


## Solving bugs {#solving-bugs}


### Code logic bugs {#code-logic-bugs}

I often solve code logic bugs in three steps:


#### Asking AI questions using plan mode with Claude Opus 4.5 {#asking-ai-questions-using-plan-mode-with-claude-opus-4-dot-5}

Prompt:

```text
<describe the bug with as much as context I know>
```

It'll search the code base and generally could find the root cause.


#### Asking AI to write unit tests to confirm the bug. {#asking-ai-to-write-unit-tests-to-confirm-the-bug-dot}

Prompt:

```text
Write unit tests to confirm your assumption.
```


#### Asking AI to solve the bug {#asking-ai-to-solve-the-bug}

Switch to build mode, and uses Claude Sonnet 4.5 to fix the bug.


#### Code review {#code-review}


#### Create an issue {#create-an-issue}

Use [gh-issue-sync](https://github.com/mitsuhiko/gh-issue-sync) skill to create an issue, which is used by QA and code reviewer to understand the changes.

Prompt:

```text
Use gh-issue-sync skill to create an issue in the form of:

## Problem
Summarize the problem.

## Solution
Your findings and changes.

## Verify
Minimal steps for QA to verify the solution.

## Claude code prompt digest
Write it using the details disclosure element.
```


#### Create a pull request {#create-a-pull-request}

Prompt:

```text
- Jira section with link to jira ticket
- Staging section (asking user)
- Summary - Brief description of the bug and fix
- Changes - Bullet list of technical changes made
- Technical Details - In-depth explanation with root cause, example, and solution
- QA Verification - Detailed test cases with numbered steps and expected results
- Closes #ISSUE_NUMBER - Link to the related issue if exists (omit if no issue)
```


## Context switching is required {#context-switching-is-required}

The ability to keep attention and fast context switching is required.


## Feedback for verification {#feedback-for-verification}

Unit tests can help AI changing code more confidently.


## Use pi coding agent {#use-pi-coding-agent}

[Pi coding agent](https://github.com/badlogic/pi-mono/tree/main/packages/coding-agent) is a coding agent with a tiny core. By using extensions, I can customize to what I need, great for suit my own workflow.

[^fn:1]: Inspired by [Agentic Coding with Claude Code](https://www.youtube.com/live/Y4_YYrIKLac)
