
# readme.el

A script to generate GitHub-Flavored Markdown files from Org documents, aimed at producing repository README files.

It uses [ox-gfm](https://github.com/larstvei/ox-gfm) and [ox-md-title.el](https://github.com/jeffkreeftmeijer/ox-md-title.el) to produce GFM files with document titles. Instead of installing them through a package manager, both packages are vendored in and loaded directly:

```emacs-lisp
(let ((directory (file-name-directory load-file-name)))
  (load (concat directory "ox-gfm/ox-gfm"))
  (load (concat directory "ox-md-title/ox-md-title")))

(require 'ox-gfm)
(require 'ox-md-title)
(org-md-title-add)
```

To generate the README, a function named `readme/to-markdown` is exposed:

```emacs-lisp
(defun readme/to-markdown (filename)
  (let ((org-md-title t)
	(make-backup-files nil))
    (org-gfm-export-as-markdown)
    (write-file filename)))
```

To run the script, run Emacs in `--batch` mode, open the file to be converted to Markdown (`README.org`, in this case), load `readme.el` and call the function with the desired output filename (`README.md`):

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
	with:
	  submodules: true
      - uses: purcell/setup-emacs@master
	with:
	  version: 28.2
      - run: emacs --batch README.org --load readme.el --eval "(readme/to-markdown \"README.md\")"
      - uses: stefanzweifel/git-auto-commit-action@v4
	with:
	  commit_message: Regenerate README.md
```