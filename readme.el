(let ((directory (file-name-directory load-file-name)))
  (load (concat directory "ox-gfm/ox-gfm"))
  (load (concat directory "ox-md-title/ox-md-title")))

(require 'ox-gfm)
(require 'ox-md-title)
(org-md-title-add)

(defun readme/to-markdown (filename)
  (let ((org-md-title t)
	(make-backup-files nil))
    (org-gfm-export-as-markdown)
    (write-file filename)))
