(defun my-python-fill-string-function (justify)
  (let ((marker (point-marker))
        (string-start-marker
         (progn
           (skip-chars-forward "\"'uUrR")
           (goto-char (python-info-ppss-context 'string))
           (skip-chars-forward "\"'uUrR")
           (point-marker)))
        (reg-start (line-beginning-position))
        (string-end-marker
         (progn
           (while (python-info-ppss-context 'string)
             (goto-char (1+ (point-marker))))
           (skip-chars-backward "\"'")
           (point-marker)))
        (reg-end (line-end-position))
        (fill-paragraph-function))
    (save-restriction
      (narrow-to-region reg-start reg-end)
      (save-excursion
        (goto-char string-start-marker)
        (delete-region (point-marker) (progn
                                        (skip-syntax-forward "> ")
                                        (point-marker)))
        (goto-char string-end-marker)
        (delete-region (point-marker) (progn
                                        (skip-syntax-backward "> ")
                                        (point-marker)))
        (save-excursion
          (goto-char marker)
          (fill-paragraph justify))
        ;; If there is a newline in the docstring lets put triple
        ;; quote in it's own line to follow pep 8
        (when (save-excursion
                (re-search-backward "\n" string-start-marker t))
          (newline-and-indent)
          (when (looking-at "[\"']$")
            (insert-before-markers (make-string 2 (nth 3 (syntax-ppss)))))
          (goto-char string-start-marker)
          (skip-chars-backward "uUrR")
          (when (looking-back "\\(^\\|[^\"']\\)[\"']")
            (insert-before-markers (make-string 2 (nth 3 (syntax-ppss)))))
          (newline-and-indent)
          (fill-region string-start-marker
                       string-end-marker
                       justify))))
    t))

(provide 'python-extra)