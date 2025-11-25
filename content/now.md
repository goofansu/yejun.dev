---
title: "What I'm doing now"
author: ["Yejun Su"]
date: 2025-07-31T11:38:00+08:00
lastmod: 2025-11-25T18:03:46+08:00
tags: ["personal"]
draft: false
---

(This page records my recent status. It's inspired by [Derek Sivers](https://sive.rs/now).)


## Self-hosting {#self-hosting}

Kamal is a great tool for deployment, which requires only SSH and Docker. I use it to deploy not only Rails applications but also self-hosted services, as described in [Kamal]({{< relref "kamal" >}}). It brings back the real joy of hosting things on bare-metal machines. For example, the steps I take to deploy [linkding](https://links.yejun.dev/) with [kamal-services](https://github.com/goofansu/kamal-services):

1.  Configure DNS on Cloudflare
2.  Add secrets in Bitwarden Secrets Manager
3.  Run `make <service>`


## 4K Monitor {#4k-monitor}

Just purchased a [4K monitor]({{< relref "my-4k-monitor-setup" >}}), and I regret not having it earlier.


## Agentic coding {#agentic-coding}

I’ve been using Claude Code and sometimes Amp for [agentic coding]({{< relref "agentic-coding" >}}) in my daily work. I’m also starting experiments with v0 to create concept prototypes using [shadcn/ui](https://ui.shadcn.com/docs/installation/vite) components, which I could use directly in my Rails+Vite project.
