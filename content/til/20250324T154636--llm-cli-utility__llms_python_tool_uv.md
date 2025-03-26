---
title: "LLM CLI utility"
author: ["Yejun Su"]
date: 2025-03-24T15:46:00+08:00
tags: ["llms", "python", "tool", "uv"]
draft: false
---

Install `llm`:

```shell
uv tool install llm
```

Install [plugins](https://llm.datasette.io/en/stable/plugins/directory.html):

```shell
llm install llm-mlx llm-ollama llm-gemini llm-mistral llm-openrouter llm-sentence-transformers llm-cmd llm-jq
```

Install `llm` with its plugins in one line (great to re-install the environment):

```shell
uv tool install llm --with llm-mlx --with llm-ollama --with llm-gemini --with llm-mistral --with llm-openrouter --with llm-sentence-transformers --with llm-cmd --with llm-jq
```

`llm-mlx` requires Python 3.12 or lower, there are two ways to set Python version.

Environment variable:

```shell
export UV_PYTHON=3.12
```

Command line option:

```shell
uv tool install llm --python 3.12
```

Update tools is as easy as `uv tool upgrade --all`.
