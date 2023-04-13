(defun readme/as-markdown ()
  (require 'ox-md)
  (org-md-export-as-markdown)
  (princ (buffer-string)))
