(defparameter *last* nil)

(defun mov (file newfile)
  (let
      ((temp nil))
    (progn
      (with-open-file (in file)
        (loop for line = (read-line in nil) while line do
              (push line temp)))
      (ensure-directories-exist newfile)
      (with-open-file (out newfile :direction :output :if-exists :supersede)
        (loop for line in (reverse temp) do
              (format out "~a~%" line)))
      (delete-file file))))

(defun del (file)
  (delete-file file))

(defun ren (file newfile)
  (rename-file file newfile))
(defun tpl (name)
  (progn
    (format t "~a: ~%" name)
    (read-line)))

(defun eval-file (filename)
  (with-open-file (in filename)
    (loop for line = (read-line in nil) while line do
          (if (equal line "") nil (eval-line line)))
    t))

(defun eval-line (line)
  (cond 
    ((char= (elt line 0) #\>) 
     (content line))
    (t (funcall (get-command line) (get-body line)))))

(defun content (line)
  (append-to-file (subseq line 2 (- (length line) 1)) *last*))

(defun append-to-file (text file)
  (with-open-file (out file :direction :output :if-exists :append)
    (write-line text out)))

(defun & (&rest parts)
  (reduce (lambda(x y) (concatenate 'string x "/" y)) parts))

(defun get-command (line)
  (read-from-string line))
(defun get-body (line)
  (eval (read-from-string line t nil :start 3)))

(defun cnf (file)
  (progn 
    (ensure-directories-exist file)
    (with-open-file (out file :direction :output :if-does-not-exist :create)
    t)
    (setf *last* file)
    (print *last*)))

(defun cnd (path)
  (ensure-directories-exist path))

(defun inc (file)
  (eval-file file))

(defun main () 
  (progn
    (format t "Template: ")
    (eval-file (concatenate 'string "~/.local/share/filescript/" (read-line) ".fscript"))))

