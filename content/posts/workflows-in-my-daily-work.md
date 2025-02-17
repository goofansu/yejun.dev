---
title: "Workflows in my daily work"
author: ["Yejun Su"]
date: 2021-09-01T00:00:00+08:00
tags: ["work"]
draft: false
---

In this post, I mainly talked about how I handle Jira tickets.


## Principles {#principles}

-   Focus on one thing at a time
-   Avoid starting from scratch
-   Don't repeat yourself


## Focus on one thing at a time {#focus-on-one-thing-at-a-time}

Notion[^fn:1] and Workona[^fn:2] are the cornerstones in my workflows.

Every time I'm going to process a Jira ticket, I save it to Notion with the
[Notion Web Clipper](https://www.notion.so/help/web-clipper) extension, then apply a pre-defined template to the
Notion page. For example, there are four basic templates for Jira tickets: Bug,
Task, Story and Epic, I apply the template according to the type of ticket, then
snippets or scripts are auto filled, it really saves me large amounts of time.

The most interesting part is for **Story** and **Epic**. I create a Workona
workspace for them when I begin to develop, it helps me focus on one thing at a
time. When things are done, I archive the workspace for later reference, I can
recover all tabs, notes and tasks at any time.

For Epic, I also create a **Board View** in Notion, then link all related pages to
the Epic, it helps me to quickly get a glance on how things are going.

For each _In Progress_ ticket, [Zapier](https://zapier.com/) helps to create a GitHub issue
automatically. Later I either convert it to a pull request or copy-paste the
contents from Notion to help others know how to handle such tickets in the
future.


## Avoid starting from scratch {#avoid-starting-from-scratch}

There are always similar tasks that have been done before, so take advantage of
existing solutions is better than start from scratch.


### Search before going {#search-before-going}

I search Jira or GitHub before I start to process, it can reduce much time on
investigating, debugging and developing.

I created some custom queries to ease the search with Alfred's Web Search functionality:

-   Search Jira tickets: `https://JIRA_CLOUD_DOMAIN/secure/QuickSearch.jspa?searchString={query}`
-   Search my own issue: `https://github.com/issues?q=is%3Aissue+is%3Aopen+assignee%3Agoofansu+archived%3Afalse+{query}`
-   Search the whole GitHub: `https://github.com/search?q={query}&ref=opensearch`


### Utilize the command line tools {#utilize-the-command-line-tools}

-   Required softwares: [gh](https://github.com/cli/cli) and [fzf](https://github.com/junegunn/fzf)
-   Checkout any pull request: `gh pr list | fzf | awk '{print $1}' | read -l result; and gh pr checkout $result`
-   Checkout any git branch: `git branch | fzf | awk '{print $1}' | read -l result; and git checkout $result`


## Don't repeat yourself {#don-t-repeat-yourself}

-   If some scripts are always used, I create a rake task and submit to the repo.
-   If some scripts need to run among several servers, I create ansible playbooks,
    execute a command and waiting for results coming to my machine.

[^fn:1]: [Notion](https://www.notion.so/) is an all-in-one note-taking app.
[^fn:2]: [Workona](https://workona.com/) is a browser extension that manages your tabs into projects.
