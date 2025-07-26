---
title: "shot-scraper CLI utility"
author: ["Yejun Su"]
date: 2025-02-14T12:15:00+08:00
tags: ["python", "scraping"]
draft: false
---

[shot-scraper](https://shot-scraper.datasette.io/en/stable/) is the second tool created by [Simon Willison](https://simonwillison.net/) that I've installed on my machine, the first being [llm](https://llm.datasette.io/en/stable/index.html).

I install Python tools using [uv](https://docs.astral.sh/uv/).

```shell
uv tool install shot-scraper
shot-scraper install # install browsers
```

Take a screenshot:

```shell
shot-scraper shot https://yejun.dev
```

Record an HTTP Archive (HAR) file:

```shell
shot-scraper har https://yejun.dev
```

View the file using [Chrome HAR Viewer](https://ericduran.github.io/chromeHAR/?url=https://gist.githubusercontent.com/goofansu/33efda715954792d3297c971f012e7e2/raw/e9ed873dc128044b01a8fdffaa668cb5f8858d5d/yejun-dev.har).
