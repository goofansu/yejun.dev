---
title: "Claude Code in Action"
author: ["Yejun Su"]
date: 2025-07-20T14:06:00+08:00
tags: ["claude", "course"]
draft: false
---

<https://anthropic.skilljar.com/claude-code-in-action>

-   Tips
    -   **`#`:** set memory
    -   **`@`:** mention files
    -   **`Ctrl-v`:** paste image

-   Context
    -   **Escape:** interrupt and redirect the conversation
    -   **Double-tap Escape:** rewind the conversation
    -   **/compact:** summarize current conversation for things learned and continue a related task
    -   **/clear:** dump current conversation and start an unrelated task

-   Intelligence
    -   Planning mode for breadth-first tasks
    -   Thinking mode for depth-first tasks. Use keywords (sorted from less to more tokens):
        -   **Think:** Basic reasoning
        -   **Think more:** Extended reasoning
        -   **Think a lot:** Comprehensive reasoning
        -   **Think longer:** Extended time reasoning
        -   **Ultrathink:** Maximum reasoning capability

-   Custom commands
    -   Create a markdown in `.claude/commands/<COMMAND>.md`.
    -   In the command, use `$ARGUMENTS` to receive user prompt. For example,
        -   Create `.claude/commands/test.md`:
            ```text
            Your task is to write tests for $ARGUMENTS
            ```
        -   Usage: `/test the User model`
    -   I found if you create commands in `~/.claude/commands/`, they become global. For example,
        -   Create `~/.claude/commands/backup.md`:
            ```text
            Create a backup for ~/.claude/CLAUDE.md using gist
            ```
        -   Use in any conversation: `/backup`

-   MCP servers
    -   Add server
        ```shell
        claude mcp add playwright npx @playwright/mcp@latest
        ```
    -   Pre-configure permissions: open the `.claude/settings.local.json` file and add the server to the `allow` array:
        ```json
        {
          "permissions": {
            "allow": ["mcp__playwright"],
            "deny": []
          }
        }
        ```
