
# readme.el

A script to generate GitHub-Flavored Markdown files from Org documents, aimed at producing repository README files. It uses [ox-gfm](https://github.com/larstvei/ox-gfm) and [ox-md-title.el](https://github.com/jeffkreeftmeijer/ox-md-title.el) to produce GFM files with titles.

The script starts by bootstrapping [straight.el](https://github.com/radian-software/straight.el) to allow installing packages from git repositories:<sup><a id="fnr.1" class="footref" href="#fn.1" role="doc-backlink">1</a></sup>

```emacs-lisp
(defvar bootstrap-version)
(let ((bootstrap-file
       (expand-file-name "straight/repos/straight.el/bootstrap.el" user-emacs-directory))
      (bootstrap-version 6))
  (unless (file-exists-p bootstrap-file)
    (with-current-buffer
	(url-retrieve-synchronously
	 "https://raw.githubusercontent.com/radian-software/straight.el/develop/install.el"
	 'silent 'inhibit-cookies)
      (goto-char (point-max))
      (eval-print-last-sexp)))
  (load bootstrap-file nil 'nomessage))
```

Ox-gfm is [available on Melpa](https://melpa.org/#/ox-gfm), while ox-md-title is installed from its [git repository](https://github.com/jeffkreeftmeijer/ox-md-title.el). Both are installed with straight.el and initialized:

```emacs-lisp
(straight-use-package 'ox-gfm)

(straight-use-package
 '(ox-md-title :type git :host github :repo "jeffkreeftmeijer/ox-md-title.el"))

(require 'ox-md-title)
(org-md-title-add)
```

Finally, a function named `readme/to-markdown` is exposed:

```emacs-lisp
(defun readme/to-markdown (filename)
  (let ((org-md-title t)
	(make-backup-files nil))
    (org-gfm-export-as-markdown)
    (write-file filename)))
```

To run the script, run Emacs in `--batch` mode, open `README.org`, load `readme.el` and call the function with the desired output filename:

```shell
emacs --batch README.org --load readme.el --eval "(readme/to-markdown \"README.md\")"
```

To automatically generate README files on GitHub, add `readme.el` to your repository and add a workflow that calls it:

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
      - uses: purcell/setup-emacs@master
	with:
	  version: 28.2
      - run: emacs --batch README.org --load readme.el --eval "(readme/to-markdown \"README.md\")"
      - uses: stefanzweifel/git-auto-commit-action@v4
	with:
	  commit_message: Regenerate README.md
```

## Footnotes

<sup><a id="fn.1" class="footnum" href="#fnr.1">1</a></sup> Straight.el is used because it's a simple way to install packages without them having to be available on a package archive, without depending on `use-package` or `package-vc-install` (both of which are only available on pre-release versions of Emacs).