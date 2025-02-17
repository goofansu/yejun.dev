---
title: "Manage runtime versions with asdf"
author: ["Yejun Su"]
date: 2022-03-08T00:00:00+08:00
tags: ["asdf"]
draft: false
---

To manage various runtime versions, almost all languages has their own version
managers, for example, here is a short list:

-   Ruby: [rvm](https://github.com/rvm/rvm) and [rbenv](https://github.com/rbenv/rbenv)
-   Python: [pyenv](https://github.com/pyenv/pyenv) and [virtualenv](https://github.com/pypa/virtualenv)
-   NodeJS: [nvm](https://github.com/nvm-sh/nvm)
-   Erlang: [kerl](https://github.com/kerl/kerl)
-   Elixir: [kiex](https://github.com/taylor/kiex)
-   Go: [gvm](https://github.com/moovweb/gvm) and [goenv](https://github.com/syndbg/goenv)

If you are using multiple runtimes for development, you may face the pitfalls to
install and maintain different kinds of version managers. Although it is not
cumbersome to use any of them, there is an overhead of context switching in your
brain. So [asdf](https://asdf-vm.com/) comes to the rescue.


## What is asdf? {#what-is-asdf}

> `asdf` is a tool version manager. All tool version definitions are contained
> within one file (`.tool-versions`) which you can check in to your project's Git
> repository to share with your team, ensuring everyone is using the exact same
> versions of tools.
>
> -- <https://asdf-vm.com/guide/introduction.html#introduction>

The target of `asdf` target is to "Manage all your runtime versions with one
tool!". It achieves the target through [plugins](https://github.com/asdf-vm/asdf-plugins?tab=readme-ov-file#plugin-list), internally, it uses the
version managers mentioned above, but as a unified command line.


## How to use asdf? {#how-to-use-asdf}

First, [install asdf](https://asdf-vm.com/guide/getting-started.html) on your machine. Then, it comes to the real cases, here we
use Ruby and NodeJS for examples:

```shell
# List all plugins
asdf plugin list all

# Install plugins for runtimes
asdf plugin add ruby
asdf plugin add nodejs

# List installed plugins
asdf plugin list

# List all verions
asdf list all ruby
asdf list all nodejs

# Install a version
asdf install ruby 2.7.5
asdf install nodejs 16.13.0

# View installed version
asdf list ruby
asdf list nodejs

# Use runtimes in current project
asdf local ruby 2.7.5
asdf local nodejs 16.13.0

# Use runtimes globally
asdf global ruby 2.7.5
asdf global nodejs 16.13.0

# Use runtimes only in current shell
asdf shell ruby 2.7.5
asdf shell nodejs 16.13.0

# Check runtimes that are currently using
asdf current
```

It absolutely reduces the complexity of managing runtime versions with asdf, I
recommend to have a try and you’ll love it.
