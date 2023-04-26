
# Generate repository README files from Org documents

- [`readme.el`](#org7a43cf6)

A widespread standard amongst code hosting platforms is for repositories to have a file named `README.md`, which is then used as the description on the repository page. Generally, this file is written in Markdown, but other formats work too.

Aside from Markdown, GitHub support Org files too. However, the support for Org lacks most advanced features, producing HTML representations which include remnants of the Org files they're generated from.<sup><a id="fnr.1" class="footref" href="#fn.1" role="doc-backlink">1</a></sup> Using a Markdown-based README still produces the most reliable results.

For example, all of the code for [ox-md-title.el](https://github.com/jeffkreeftmeijer/ox-md-title.el) is written inside an Org document in an attempt to write its documentation and implementation in a single source file. With a setup like that, maintaining a separate README file defeats the purpose of having the Org file as a signgle source of truth. Instead, it'd be useful to generate the README&#x2014;in Markdown format&#x2014;from the Org file as well.

To generate a Markdown file from an Org document, run `org-md-export-to-markdown` in Emacs' batch mode:

```shell
emacs --batch ox-html-title.org --funcall org-md-export-to-markdown
```

This produces a Markdown representation of `ox-html-title.org` in `ox-html-title.md`.


<a id="org7a43cf6"></a>

## `readme.el`

[`readme.el`](https://github.com/jeffkreeftmeijer/readme.el) is a script to generate Markdown files from Org documents, aimed at producing repository README files to be used on GitHub. It has some advantages over running `org-md-export-to-markdown`:

1.  It uses [ox-gfm](https://github.com/larstvei/ox-gfm) to produce *GitHub-flavored Markdown*, a dialect of Markdown which adds some features, like [fenced code blocks](https://github.github.com/gfm/#fenced-code-blocks), which add syntax highlighting capabilities.
2.  It uses [ox-md-title.el](https://github.com/jeffkreeftmeijer/ox-md-title.el) to add document titles to the produced Markdown documents, which is not enabled by default in Org mode's Markdown exporters.
3.  It takes a filename, allowing a file named `ox-html-title.org` to produce a file named `README.md` instead of `ox-html-title.md`.

The package dependencies are vendored in, so they don't need to be downloaded with a package manager. Instead, the script loads them from its local submodules, requires them, and sets up `ox-md-title`:

```emacs-lisp
(let ((directory (file-name-directory load-file-name)))
  (load (concat directory "ox-gfm/ox-gfm"))
  (load (concat directory "ox-md-title/ox-md-title")))

(require 'ox-gfm)
(require 'ox-md-title)
(org-md-title-add)
```

A function named `readme/to-markdown` is exposed, which is called to create the README file. Before generating the file, it turns on `ox-md-title`'s `org-md-title` option and disables backup file creation. Then it generates the Markdown file and stores it in the location passed via the `filename` argument:

```emacs-lisp
(defun readme/to-markdown (filename)
  (let ((org-md-title t)
	(make-backup-files nil))
    (org-gfm-export-as-markdown)
    (write-file filename)))
```

To run the script, run Emacs in `--batch` mode, open the file to be converted to Markdown (`org-readme.org`, for example), load `readme.el` and call the function with the desired output filename (`README.md`):

```shell
emacs --batch org-readme.org --load readme.el --eval "(readme/to-markdown \"README.md\")"
```

To automatically generate README files on GitHub, add `readme.el` to your repository as a submodule and add a workflow that calls it. For example, the repository for `readme.el` includes [a workflow](https://github.com/jeffkreeftmeijer/readme.el/tree/main/.github/workflows) that automatically updates its README:<sup><a id="fnr.2" class="footref" href="#fn.2" role="doc-backlink">2</a></sup>

```yaml
name: README.md

on:
  push:
    branches: [ "main" ]

jobs:
  generate:
    runs-on: ubuntu-latest

    permissions:
      contents: write

    steps:
      - uses: actions/checkout@v3
	with:
	  submodules: true
      - uses: purcell/setup-emacs@master
	with:
	  version: 28.2
      - run: emacs --batch org-readme.org --load readme.el --eval "(readme/to-markdown \"README.md\")"
      - uses: stefanzweifel/git-auto-commit-action@v4
	with:
	  commit_message: Regenerate README.md
```

## Footnotes

<sup><a id="fn.1" class="footnum" href="#fnr.1">1</a></sup> For example, [this document](https://github.com/jeffkreeftmeijer/ox-md-title.el/blob/0.1.0/ox-md-title.org) uses some features not supported by GitHub:

1.  Inline code blocks (`src_org`: `+#title`, `src_html`: `<title>`) aren't replaced.
2.  Code blocks aren't executed and `:exports` options are ignored, showing the code block when only the results should be included.
3.  Noweb doesn't work, leaving unreplaced tags like `<<template>>` in the code blocks.
4.  Footnotes don't work, meaning the reference (`[fn:patch]`) is left in the file and the footnote isn't replaced with footnote markup.

While the inline code blocks and footnotes could be fixed, it's no surprise that the code blocks aren't executed and files aren't tangled.

<sup><a id="fn.2" class="footnum" href="#fnr.2">2</a></sup> Other projects that use `readme.el` in their workflows include [ox-md-title.el](https://github.com/jeffkreeftmeijer/ox-md-title.el/blob/develop/.github/workflows/markdown.yml) and [ox-html-stable-ids.el](https://github.com/jeffkreeftmeijer/ox-html-stable-ids.el/blob/develop/.github/workflows/readme.yml).