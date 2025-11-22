(let ((directory (file-name-directory load-file-name)))
  (unless (require 'ox-gfm nil t)
    (require 'ox-gfm (concat directory "ox-gfm/ox-gfm")))

  (unless (require 'ox-md-title nil t)
    (require 'ox-md-title (concat directory "ox-md-title/ox-md-title"))))

(org-md-title-add)

(defun readme/to-markdown (filename)
  (let ((org-md-title t)
        (make-backup-files nil))
    (org-gfm-export-as-markdown)
    (write-file filename)))
