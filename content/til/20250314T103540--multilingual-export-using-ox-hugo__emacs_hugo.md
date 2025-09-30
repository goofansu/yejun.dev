---
title: "Multilingual export using ox-hugo"
author: ["Yejun Su"]
date: 2025-03-14T10:35:00+08:00
tags: ["emacs", "hugo"]
draft: false
---

[Hugo-modus](https://github.com/goofansu/hugo-modus) supports multilingual now, it'll display translation links for multilingual posts. As I'm [blogging using Denote and Hugo]({{< relref "blogging-using-denote-and-hugo" >}}), I changed the `#+export_file_name` by appending the locale such as: `post-1.zh`, expecting it to export `post-1.zh.md` but failed. The complete configuration is as the following:

```org
#+hugo_base_dir: ~/code/hugo-modus/exampleSite
#+hugo_section: posts
#+export_file_name: post-1.zh
```

Then I found there is already a [solution](https://github.com/kaushalmodi/ox-hugo/issues/157#issuecomment-385027369), which is as easy as appending `.md`, such as `#+export_file_name: post-1.zh.md`. The result is [on the example site](https://hugo-modus.yejun.dev/zh/posts/post-1/).
