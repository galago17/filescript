(require :uiop) 

(defun main () (let ((args (uiop:command-line-arguments)))
  (format t "Arguments received: ~a~%" args)
))

