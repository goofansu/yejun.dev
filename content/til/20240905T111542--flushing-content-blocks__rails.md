---
title: "Flushing content blocks"
author: ["Yejun Su"]
date: 2024-09-05T11:15:00+08:00
tags: ["rails"]
draft: false
---

By default, multiple calls of the `content_for` helper using the same identifier will concatenate and output them together.

Set `flush: true` to flush all previous `content_for` calls:

```html
<% content_for :example %>
This block is flushed.
<% end %>

<% content_for :example flush: true do %>
This block will display.
<% end %>
```
