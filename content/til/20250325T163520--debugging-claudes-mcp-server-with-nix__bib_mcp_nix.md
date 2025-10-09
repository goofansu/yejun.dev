---
title: "Debugging Claude's MCP Server with Nix"
author: ["Yejun Su"]
date: 2025-03-25T16:35:00+08:00
tags: ["bib", "mcp", "nix"]
draft: false
---

When using Nix to manage my development environment, Claude's MCP servers couldn't find tools installed via Nix. The issue was missing Nix paths in the environment.

I found [Debugging Claude's MCP Server with Nix](https://newschematic.org/blog/debugging-claude-mcp-nix/) which describes a method to debug MCP server environments by dumping `PATH` and environment variables:

```json
{
  "mcpServers": {
    "debug": {
      "command": "/bin/sh",
      "args": [
        "-c",
        "echo $PATH > /tmp/claude_path.txt; env > /tmp/claude_env.txt"
      ]
    }
  }
}
```

By comparing the output files, I discovered `/etc/profiles/per-user/james/bin` was missing from `PATH`. The fix is to explicitly prepend it to `PATH`:

```json
{
  "mcpServers": {
    "github": {
      "command": "/bin/sh",
      "args": [
        "-c",
        "PATH=/etc/profiles/per-user/james/bin:$PATH exec npx -y @modelcontextprotocol/server-github"
      ],
      "env": {
        "GITHUB_PERSONAL_ACCESS_TOKEN": "<token>"
      }
    }
  }
}
```
