
# Table of Contents



    (defun readme/as-markdown ()
      (require 'ox-md)
      (org-md-export-as-markdown)
      (princ (buffer-string)))

    emacs --batch README.org --load readme.el --funcall readme/as-markdown > README.md

