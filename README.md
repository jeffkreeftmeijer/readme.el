```emacs-lisp
(defun readme/as-markdown ()
  (use-package ox-gfm)

  (org-gfm-export-as-markdown)
  (princ (buffer-string)))
```

```shell
emacs --batch README.org --load readme.el --funcall readme/as-markdown > README.md
```