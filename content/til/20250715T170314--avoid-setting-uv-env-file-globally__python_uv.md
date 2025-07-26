---
title: "Avoid setting UV_ENV_FILE globally"
author: ["Yejun Su"]
date: 2025-07-15T17:03:00+08:00
tags: ["python", "uv"]
draft: false
---

I'm using the [Atlassian Remote MCP Server](https://community.atlassian.com/forums/Atlassian-Platform-articles/Using-the-Atlassian-Remote-MCP-Server-beta/ba-p/3005104) in Claude Code to fetch Jira tickets. I installed it per-project using `claude mcp add-json <name> <string>`. Recently, I noticed it keeps failing in one project, although the config is exactly the same.

I checked the problem by locating the MCP server command and executing it within the project. The error raised: `` No environment file found at: `.env` ``. It reminded me that `UV_ENV_FILE=.env` is set globally, and it's too convenient to be noticed. After removing the environment variable, the MCP server works.
