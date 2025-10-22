---
title: "Livebook-driven development"
author: ["Yejun Su"]
date: 2021-06-08T00:00:00+08:00
tags: ["elixir", "livebook"]
draft: false
---

Last week I published [ogp](https://github.com/goofansu/ogp) which is a simple wrapper for Open Graph
protocol. Coding is easy, I want to share the progress of developing it in
Livebook.


## What is Livebook? {#what-is-livebook}

[Livebook](https://github.com/elixir-nx/livebook) is a notebook for writing Elixir and Markdown in an interactive way. We
can evaluate Elixir code blocks and see the results immediately.

There are several methods to run Livebook, I choose the escript way.

```shell
$ mix escript.install hex livebook
$ livebook server
[Livebook] Application running at http://localhost:8080/?token=xxxxx
```

Livebook is running now! Just open it in a browser. Click the **New Notebook**
button and start to write Elixir. With Elixir 1.12, you get the ability to run
libraries after `Mix.install/1` them.

{{< figure src="/attachments/20250127T003232--livebook-1.png" >}}


## How does Livebook benefit the development process? {#how-does-livebook-benefit-the-development-process}

Before Livebook, I write code in [IEx](https://elixir-lang.org/getting-started/introduction.html#interactive-mode), which is a REPL. It has some [helpers](https://elixirschool.com/en/lessons/basics/iex-helpers/) to
ease the way to explore code, but in my opinion, Livebook exceeds in two
factors:


### Code history {#code-history}

In fact, IEx can enable code history by setting `export ERL_AFLAGS="-kernel
shell_history enabled"` in the shell profile file. You can also search the IEx
code history with **Ctrl-r** and apply it. But as Livebook is essentially a
notebook, you can see all texts and evaluation results without the need to set
anything.


### Visualization {#visualization}

Livebook has a clean UI. You can write documents in Markdown and evaluate Elixir
code blocks. It is more continuous, you can review every step of your thought by
scrolling the page.


## How to develop in Livebook? {#how-to-develop-in-livebook}

Use ogp as an example.


### First, I explore the idea with code blocks. {#first-i-explore-the-idea-with-code-blocks-dot}

-   Install floki[^fn:1] with `Mix.install/1`.
    ![](/attachments/20250127T003259--livebook-2.png)

-   Explore floki with Open Graph protocol.
    ![](/attachments/20250127T003309--livebook-3.png)

-   The variables in a code block can be referenced by blocks below it.
    ![](/attachments/20250127T003330--livebook-4.png)

-   As going deeper, a simple parser comes out.
    ![](/attachments/20250127T003347--livebook-5.png)


### Then I create an Elixir project and run the Livebook in the project. {#then-i-create-an-elixir-project-and-run-the-livebook-in-the-project-dot}

-   Create an Elixir project with `mix new ogp --module OpenGraph --sup`.
-   Save the Livebook file in the project.
    ![](/attachments/20250127T003403--livebook-6.gif)

-   Move the parser into the project and run Livebook in **Mix standalone** mode.

    {{< figure src="/attachments/20250127T003419--livebook-7.gif" >}}

    Connection timed out occurs, to resolve it, run Livebook with a short name:
    `livebook server --sname notebook`. See
    <https://github.com/elixir-nx/livebook/issues/275> for detail.

-   Set up **Mix standalone** mode again successfully, uses the module from the ogp
    project.

    {{< figure src="/attachments/20250127T003440--livebook-8.gif" >}}


## Conclusion {#conclusion}

Developing in Livebook is really delightful. It helps to explore the code and
writing documents. Give it a try and you will love it!

PS: The Livebook file created in this story can be found [here](https://gist.github.com/goofansu/42276a378588be1c5a7423bfb16ac88f).

---


## Update on 2021-06-09 {#update-on-2021-06-09}

Livebook supports URL input since this PR, which is a perfect
use case for ogp. See how it works:

{{< figure src="/attachments/20250127T003459--livebook-9.gif" >}}

Enjoy!

[^fn:1]: [Floki](https://github.com/philss/floki) is an HTML parser in Elixir.
