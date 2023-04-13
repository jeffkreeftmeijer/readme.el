(defun readme/as-markdown ()
  (use-package ox-gfm)

  (org-gfm-export-as-markdown)
  (princ (buffer-string)))
