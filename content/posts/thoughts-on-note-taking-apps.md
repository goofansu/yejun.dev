---
title: "Thoughts on note-taking apps"
author: ["Yejun Su"]
date: 2021-08-23T00:00:00+08:00
tags: ["pkm"]
draft: false
---

Today I tidy up my digital things into three apps: Notion, Roam Research and
Obsidian. In my opinion, they are not mutually exclusive as they have their own
focuses:

-   Notion: write and publish, focus on sharing and coordinating.
-   Roam Research: my second brain, focus on summarizing and thinking.
-   Obsidian: save code snippets, focus on private things.


## Notion {#notion}

I use Notion every day although my company uses Basecamp and Jira for project
management. It has several features that I feel grateful:

-   Database template. I set various templates for different kinds of Jira
    tickets, for example, bug, story or task. For some repeatable tickets, I set a
    template for it and write some pre-defined code blocks to speed up the
    workflow.
-   Powerful embeds. Notion supports many popular websites by embed them in a
    page, such as GitHub Gist, CodePen, Excalidraw, Figma and Sketch, etc. It
    helps me to avoid jumping among kinds of web services.
-   Easy-to-use coordination. In the three apps, Notion is the easiest one to
    share and coordinate with others. Even in the free plan, you can invite 5
    guests to your workspace. I often share the solution for a Jira ticket to my
    colleagues and talk with them, as it is a part of workflow, all things I did
    before are just not wasted.
-   Full export. In Notion, you can choose to export a page with its files and
    images, even sub-pages, while in Roam Research, you can only export a single
    markdown file.


## Roam Research {#roam-research}

Roam Research is date-centered, backlink-powered and bullet-styled.I use Roam to
summarize for things I read in Kindle or Instapaper, and write notes as
described in [Tiago Forte's review](https://fortelabs.co/blog/how-to-take-smart-notes/) of the book [How to Take Smart Notes](https://www.soenkeahrens.de/en/takesmartnotes).

Roam's backlink is very powerful, it is bottom up, so I can find the root page
from any leaf page. It also supports showing **Unlinked References** in the page,
any other page that contains the words will appear in the section, it really
helps on finding potential relative things that you may not considered. This
feature is more intuitive and useful than Notion's backlink feature.

For summarize books and articles, it works best with Readwise as

> Roam enables some powerful use cases. For example, each new highlight includes
> a backlink to your Daily Note of the day they were synced.
>
> -- [How does the Readwise to Roam export integration work?](https://help.readwise.io/article/71-how-does-the-readwise-to-roam-export-integration-work)

I like this feature as some things are time-relative, they are useful in the
context of that time, I can easily know whether they are still useful at the
moment.


## Obsidian {#obsidian}

Obsidian is based on markdown files, in other words, the file format is not
proprietary, you own the files. It best suits the need for private things. I use
it to save code snippets, as company code are not sharable.

Obsidian is extensible as it has a plugin system and an active community, so
there is no need to worry about the ecosystem. My frequent used plugins are [git](https://github.com/denolehov/obsidian-git),
[gist](https://github.com/linjunpop/obsidian-gist) and [excalidraw](https://github.com/zsviczian/obsidian-excalidraw-plugin).
