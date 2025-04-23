---
title: "Blogging using Denote and Hugo"
author: ["Yejun Su"]
date: 2025-03-04T17:17:00+08:00
tags: ["blogging", "denote", "hugo"]
draft: false
toc: true
---

I've been thinking of writing a post about my current blogging workflow for quite some time. After reading [Blogging using Emacs Org Roam and Hugo](https://sourcery.zone/articles/20250226102455-blogging_using_emacs_org_roam_and_hugo/), I noticed we have a similar approach: we both use Nix, Hugo, and ox-hugo. The main difference is that my workflow is based on Denote instead of Org Roam.

<!--more-->


## Denote {#denote}

[Denote](https://protesilaos.com/emacs/denote) is a simple note-taking tool created by Protesilaos Stavrou (known as Prot), based on the idea that notes should follow **a predictable and descriptive file-naming scheme**. The default format is `DATE==SIGNATURE--TITLE__KEYWORDS.EXTENSION`, such as `20231007T104700--static-website-with-hugo-and-nix__hugo_nix.org`. This format is both URL-friendly and easy to search.


### Attachments {#attachments}

My note-taking system is inspired by [Taking Notes With the Emacs Denote Package](https://lucidmanager.org/productivity/taking-notes-with-emacs-denote/). I'm impressed by the "Attachments" section:

> An attachment in Denote is any file that is not recognised by Denote as a note, but with a compatible filename. Any file stored in the Denote directory that follows the Denote file naming convention will be recognised as an attachment and can be linked from inside a Denote file.

I save all attachments in the `attachments` directory alongside my notes, and I insert links using `[[file:]]` syntax rather than `denote-link`. The benefits are:

-   Since most attachments are pictures, I can view them directly in an Org file using `org-toggle-inline-images`. They're also visible on GitHub.
-   Attachments in the form of `[[file:]]` are automatically copied to the `<HUGO_WEBSITE>/static/attachments/`[^fn:1] directory, with no manual work needed.

I use a function to insert attachments from any location on my computer to the current note by inserting a link if the attachment is already in the `attachments` directory, or renaming and moving the attachment to the `attachments` directory first, and then inserting a link.

```emacs-lisp
(setq my-notes-attachments-directory (expand-file-name "attachments/" (denote-directory)))

(defun my/denote-org-extras-insert-attachment (file)
    "Process FILE to use as an attachment in the current buffer.

If FILE is already in the attachments directory, simply insert a link to it.
Otherwise, rename it using `denote-rename-file' with a title derived from
the filename, move it to the attachments directory, and insert a link.

The link format used is '[[file:attachments/filename]]', following Org syntax.
This function is ideal for managing referenced files in note-taking workflows."
    (interactive (list (read-file-name "File: " my-notes-attachments-directory)))
    (let* ((orig-buffer (current-buffer))
           (attachments-dir my-notes-attachments-directory))

      ;; Check if the file is already in the attachments directory
      (if (string-prefix-p
           (file-name-as-directory attachments-dir)
           (expand-file-name file))

          ;; If already in attachments, just insert the link
          (with-current-buffer orig-buffer
            (insert (format "[[file:attachments/%s]]" (file-name-nondirectory file))))

        ;; Otherwise, rename and move the file
        (let ((title (denote-sluggify-title (file-name-base file))))
          (when-let* ((renamed-file (denote-rename-file file title))
                      (renamed-name (file-name-nondirectory renamed-file))
                      (final-path (expand-file-name renamed-name attachments-dir)))
            (rename-file renamed-file final-path t)
            (with-current-buffer orig-buffer
              (insert (format "[[file:attachments/%s]]" renamed-name))))))))
```

Here's a screencast of inserting an image from the `Desktop` directory into the current note using this function:

{{< figure src="/attachments/20250305T171116--cleanshot-2025-03-05-at-171105.gif" >}}


### Reference links {#reference-links}

I create references to my notes using `denote-link`. The problem is that after exporting, these references are converted into Markdown links that point to the original Org files, which are inaccessible on the published website:

```markdown
[Static website with Hugo and Nix](20231007T104700--static-website-with-hugo-and-nix__hugo_nix.org)
```

I add an `denote-link-ol-export advice` to solve the problem:

```emacs-lisp
(advice-add 'denote-link-ol-export :around
            (lambda (orig-fun link description format)
              (if (and (eq format 'md)
                       (eq org-export-current-backend 'hugo))
                  (let* ((path (denote-get-path-by-id link))
                         (export-file-name
                          (or
                           ;; Use export_file_name if it exists
                           (when (file-exists-p path)
                             (with-temp-buffer
                               (insert-file-contents path)
                               (goto-char (point-min))
                               (when (re-search-forward "^#\\+export_file_name: \\(.+\\)" nil t)
                                 (match-string 1))))
                           ;; Otherwise, use the original file's base name
                           (file-name-nondirectory path))))
                    (format "[%s]({{</* relref \"%s\" */>}})"
                            description
                            export-file-name))
                (funcall orig-fun link description format))))
```

Now the references use the `relref` shortcode, which is a Hugo feature to create relative links to documents:

```markdown
[Static website with Hugo and Nix]({{</* relref "static-website-with-hugo-and-nix" */>}})
```

You can visit the article here: [Static website with Hugo and Nix]({{< relref "static-website-with-hugo-and-nix" >}}).


## Hugo {#hugo}

[Hugo](https://gohugo.io/) is a fast static site generator that's easy to install with just an executable binary.


### Nix {#nix}

I use Nix for my development environment because I need `go` for [Hugo Modules](https://gohugo.io/hugo-modules/use-modules/):

```nix
{
  description = "My personal website";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        devShells.default = pkgs.mkShell {
          packages = with pkgs; [
            hugo
            go
          ];
        };
      }
    );
}
```


### Theme {#theme}

I created [hugo-modus](https://github.com/goofansu/hugo-modus/) theme specifically for this blog. It uses the [colour palette of the Modus themes](https://protesilaos.com/emacs/modus-themes-colors), and supports both light and dark modes.

Since I use hugo-modus for my blog and also work on its development, I need to switch between the local and remote versions. Fortunately, Hugo supports split configuration by environment:

```shell
config/
├── _default
│   └── hugo.toml
└── development
    └── hugo.toml
```

In `config/_default/hugo.toml`, set the theme to be used in the production environment:

```toml
[module]
  [[module.imports]]
    path = "github.com/goofansu/hugo-modus"
```

In `config/development/hugo.toml`, override the theme to use the local hugo-modus directory:

```toml
[module]
  replacements = "github.com/goofansu/hugo-modus -> ../../hugo-modus"
```

Check the active modules by running `hugo mod graph`:

```shell
> hugo mod graph -e development
project ../../hugo-modus

> hugo mod graph -e production
github.com/goofansu/yejun.dev github.com/goofansu/hugo-modus@v0.0.0-20250423135050-b8cf9a1e9268
```


## Denote + Hugo {#denote-plus-hugo}

I use [ox-hugo](https://ox-hugo.scripter.co/) to export Org-mode files to Markdown for Hugo. It offers two options for organizing posts: "One post per Org subtree" and "One post per Org file". In my blogging workflow, I choose the "One post per Org file" method because notes are just posts.

Using this post as an example, after creating the Org-mode note using the `denote` command, it contains the following content.

```org
#+title:      Blogging using Denote and Hugo
#+date:       [2025-03-04 Tue 17:17]
#+filetags:   :blogging:denote:hugo:
#+identifier: 20250304T171750
```

The note is not Hugo-exportable at the moment.


### Make note Hugo-exportable {#make-note-hugo-exportable}

Set `#+hugo_base_dir`, and that's the only necessary configuration:

```org
#+hugo_base_dir: ~/src/yejun.dev
```

By default, `M-x org-hugo-export-to-md` exports the note to `~/src/yejun.dev/content/posts/20250304T171750--blogging-using-denote-and-hugo__blogging_denote_hugo.md`.

Thanks to Denote's file-naming scheme, which creates URL-friendly names, I can export my [TILs](https://yejun.dev/til/) and [Links](https://yejun.dev/links/) using their original file names.


### But I prefer a shorter file name {#but-i-prefer-a-shorter-file-name}

Set `#+export_file_name` to define the name of the exported file:

```org
#+export_file_name: blogging-using-denote-and-hugo
```

This time, `M-x org-hugo-export-to-md` exports the note to `~/src/yejun.dev/content/posts/blogging-using-denote-and-hugo.md`.


### How does the Markdown file look? {#how-does-the-markdown-file-look}

Looking at the Markdown file, it contains a YAML front-matter[^fn:2]:

```yaml
---
title: "Blogging using Denote and Hugo"
author: ["Yejun Su"]
date: 2025-03-04T17:17:00+08:00
tags: ["blogging", "denote", "hugo"]
---
```


### Where does the front-matter come from? {#where-does-the-front-matter-come-from}

`ox-hugo` converts `#+title`, `#+date`, and `#+filetags` into Hugo front-matter and automatically includes the `author` which reads `user-full-name`. [Org meta-data to Hugo front-matter](https://ox-hugo.scripter.co/doc/org-meta-data-to-hugo-front-matter/#for-file-based-exports) lists all Hugo front-matter translations for file-based exports.

Interestingly, `#filetags` isn't included in that list; instead, there is `#+hugo_tags`. I found `#+filetags` wasn't supported until this [pull request](https://github.com/kaushalmodi/ox-hugo/pull/492), which was made to support Org Roam's parsing of tags from the `#+filetags` keyword starting with Org Roam v2.


### I want to export a TIL note {#i-want-to-export-a-til-note}

By default, `ox-hugo` exports notes as `posts`, you can change the behaviour by:

-   Setting `#+hugo_section` in the note
    ```org
    #+hugo_section: til
    ```

-   Setting the `org-hugo-default-section-directory` variable globally
    ```emacs-lisp
    (setq org-hugo-default-section-directory "til")
    ```

See [Transform ox-hugo anchors to links]({{< relref "20250204T004450--transform-ox-hugo-anchors-to-links__emacs_hugo.org" >}}) for an example.


### Can I automatically export a note every time I save it? {#can-i-automatically-export-a-note-every-time-i-save-it}

Sure. `ox-hugo` offers a [guide](https://ox-hugo.scripter.co/doc/auto-export-on-saving/) on automatically exporting when saving. Just add the following snippet at the end of the note:

```org
* Footnotes
* COMMENT Local Variables :ARCHIVE:
# Local Variables:
# eval: (org-hugo-auto-export-mode)
# End:
```


### Can I search all Hugo-exportable notes? {#can-i-search-all-hugo-exportable-notes}

Yes. The approach is simple - I just search `ripgrep` the Org files in my `denote-directory` for `#+hugo_base_dir`:

```emacs-lisp
(defun my/org-hugo-denote-files ()
    "Return a list of Hugo-compatible files in `denote-directory'."
    (let ((default-directory (denote-directory)))
      (process-lines "rg" "-l" "^#\\+hugo_base_dir" "--glob" "*.org")))

(defun my/org-hugo-denote-files-find-file ()
    "Search Hugo-compatible files in `denote-directory' and visit the result."
    (interactive)
    (let* ((default-directory (denote-directory))
           (prompt (format "Select FILE in %s: "  default-directory))
           (selected-file (consult--read
                           (my/org-hugo-denote-files)
                           :state (consult--file-preview)
                           :history 'denote-file-history
                           :require-match t
                           :prompt prompt)))
      (find-file selected-file)))
```


### Can I export all Hugo-exportable notes? {#can-i-export-all-hugo-exportable-notes}

Absolutely yes! Just loop `my/org-hugo-denote-files` and execute `org-hugo-export-to-md`:

```emacs-lisp
(defun my/org-hugo-export-all-denote-files ()
    "Export all Hugo-compatible files in `denote-directory'."
    (interactive)
    (let ((org-export-use-babel nil))
      (dolist (file (my/org-hugo-denote-files))
        (with-current-buffer (find-file-noselect file)
          (org-hugo-export-to-md)))))
```


## Conclusion {#conclusion}

-   I can publish any note to any Hugo website by setting `#+hugo_base_dir`.
-   I can publish any note to any Hugo section by setting `#+hugo_base_section`.
-   I can insert any file from my computer into any note using `denote-rename-file`.

Together, these advantages create an efficient publishing workflow.

PS: Emacs code used in this post can be found [here](https://github.com/goofansu/emacs-config/blob/main/modules/init-writing.el).

[^fn:1]: `ox-hugo` by default copies files to `static/ox-hugo` directory, I changed the behaviour by customizing `org-hugo-default-static-subdirectory-for-externals` to `"attachments"`.
[^fn:2]: `ox-hugo` supports exporting the front-matter in TOML (default) or YAML. I prefer YAML and have customized `org-hugo-front-matter-format` to use `"yaml"`.
