---
title: "Agentic coding"
author: ["Yejun Su"]
date: 2025-07-26T11:05:00+08:00
lastmod: 2026-07-21T00:32:45+08:00
tags: ["ai"]
draft: false
toc: true
state: "seedling"
---

I work with agents mostly in TUI with `gh/tmux/worktrunk/fzf`.

Principles:

1.  Use one worktree per branch with [Worktrunk](https://worktrunk.dev)
2.  Dispatch tasks to agents in a new [Tmux](https://github.com/tmux/tmux) window


## Context {#context}


### Project context {#project-context}

I maintain project context using git worktrees. In this way, it's easy to develop in parallel while preserving context for code agents.

Use `openapply` as an example,

Fix a bug based on the `master` branch:

```shell
cd openapply
wt switch -c fix-bug -b master # Create fix-bug branch and switch to openapply.fix-bug directory
```

Develop on a new feature (omit `-b` to use the default branch):

```shell
cd openapply
wt switch -c new-feature # Create new-feature branch and switch to openapply.new-feature directory
```

Tip: Worktrunk provides hooks to set up your environment for new worktrees.


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


## Skills {#skills}

I use a combination of [obra/superpowers](https://github.com/obra/superpowers) + [mattpocock/skills](https://github.com/mattpocock/skills) + my own skills:

Superpowers is a methodology enforcing spec -&gt; implementation, and it uses skills according to the scope of tasks, for example:

-   Feature development: brainstorming -&gt; writing-plans -&gt; subagent-driven-development -&gt; verification-before-completion
-   Bug fixing: systematic-debugging -&gt; test-driven-development

Matt's skills is more like copilot with agent:

-   grill-with-docs: it depends on grilling and domain-modeling (from [Domain-Driven Design](https://en.wikipedia.org/wiki/Domain-driven_design))
-   codebase-design: write good code by designing deep modules (from [A Philosophy Of Software Design](https://web.stanford.edu/~ouster/cgi-bin/aposd.php))

My skills:

-   commit: create Conventional Commits commits
-   handoff: write a handoff document, and optionally launch an agent in Tmux for the handoff


## Tools {#tools}

Tools are mostly command line utilities.


### agent-browser {#agent-browser}

Link: <https://agent-browser.dev/>

```shell
npm install -g agent-browser
agent-browser install
```


## Workflow {#workflow}

I delegate work to agents using the [gh-ai extension](https://github.com/goofansu/nix-config/blob/main/scripts/gh-ai.fish) in [gh-dash](https://github.com/goofansu/nix-config/blob/9f350c778863ccb648c6f459729de743d787bc4f/git.nix#L104-L140).

```text
gh ai - Agent workflow helpers for GitHub issues and pull requests

USAGE
  gh ai <command> [flags]

COMMANDS
  import <url>
      Inspect a URL and create a GitHub issue
  triage [issue-number | gh issue list filters...]
      Analyze an issue and create or update its implementation plan
  implement [issue-number | gh issue list filters...]
      Implement an issue plan by number, or select an issue with fzf
  implement --pr [pr-number | gh pr list filters...]
      Continue implementation on a PR by number, or select one with fzf
  review [pr-number | gh pr list filters...]
      Review a PR by number, or select one with fzf
  help
      Show this help

COMMON FLAGS
  --prompt PROMPT  Custom prompt template for the agent.

COMMAND FLAGS
  implement:
    --base BASE      Branch to start issue implementation from. Omit to use the default branch.
    --branch BRANCH  Branch to create for issue implementation. Defaults to issue-<number>-<title-slug>.
    --pr             Continue implementation from a pull request instead of an issue.

PROMPT VARIABLES
  import:        {url}
  triage:        {issue}
  implement:     {issue}, {branch}, {base}
  implement --pr:{pr}
  review:        {pr}

EXAMPLES
  gh ai import https://example.com/ticket/123
  gh ai triage 123 --prompt 'Triage issue {issue}'
  gh ai implement 123 --prompt 'Implement issue {issue}'
  gh ai implement --pr 456 --prompt 'Continue PR {pr}'
  gh ai review 456 --prompt '/review {pr}. Focus on regression risk'
```

[^fn:1]: Inspired by [Agentic Coding with Claude Code](https://www.youtube.com/live/Y4_YYrIKLac)
