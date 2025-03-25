---
title: "Debugging Claude's MCP Server with Nix"
author: ["Yejun Su"]
date: 2025-03-25T16:35:00+08:00
tags: ["mcp", "nix"]
draft: false
---

[Debugging Claude's MCP Server with Nix](https://newschematic.org/blog/debugging-claude-mcp-nix/)

The post introduces a method to debug the environment of Claude MCP servers.

> To debug this, I used a shell script (suggested by Claude) to save the PATH and environment variables at MCP startup:
>
> ```json
> {
>   "mcpServers": {
>     "filesystem": {
>       "command": "/bin/sh",
>       "args": [
>         "-c",
>         "echo $PATH > /tmp/claude_path.txt; env > /tmp/claude_env.txt"
>       ]
>     }
>   }
> }
> ```
>
> -- Chris Boette

Like Chris Boette, I manage my dev environment using Nix, and having the same problem. By comparing `claude_path.txt` and `claude_env.txt`, I found `/etc/profiles/per-user/james/bin` is missing in the `PATH` environment variables. And it works after changing to the following:

````json
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
````
