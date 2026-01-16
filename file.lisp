(defparameter *last* nil)
(defparameter *tpls* (make-hash-table :test #'equal))
(defparameter *content* nil)

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
      (delete-file file)
      (format t "Moved ~a -> ~a~%" file newfile))))

(defun del (file)
  (delete-file file)
  (format t "Deleted ~a~%" file))

(defun ren (file newfile)
  (rename-file file newfile)
  (format t "Renamed ~a -> ~a~%" file newfile))

(defun tpl (name)
  (progn
    (format t "~a: ~%" name)
    (let ((val (read-line)))
      (setf (gethash name *tpls*) val)
      val)))

(defun val (name)
  (gethash name *tpls*))

(defun eval-file (filename)
  (with-open-file (in filename)
    (loop for line = (read-line in nil) while line do
          (if (equal line "") nil (eval-line line)))
    t))

(defun eval-line (line)
  (cond 
    ((char= (elt line 0) #\<) 
     (setf *content* t))
    ((char= (elt line 0) #\>)
     (setf *content* nil))
    (*content* (add line))
    ((char= (elt line 0) #\#)
     (format t "~a~%" line))
    (t (funcall (get-command line) (get-body line)))))

(defun add (body)
  (append-to-file body *last*)
  (format t "+ ~a~%" body))

(defun str (&rest parts)
  (reduce (lambda(x y) (concatenate 'string x y)) parts))
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
    (format t "Created ~a~%" file)))
    

(defun cnd (path)
  (ensure-directories-exist (concatenate 'string path "/"))
  (format t "Created ~a/~%" path))

(defun inc (file)
  (eval-file file))

(defun print-documentation ()
  (format t "~{~a~%~}" (list "filescript mode filepath" "mode == template -> filepath is relative to HOME/.local/share/filescript and filepath is the name of the template without the .fscript extension" "mode == local -> filepath is local")))

(defun main ()
  (let* (
         (args (uiop:command-line-arguments))
         (mode (first args))
         (file (second args)))
    (cond
      ((equal mode "template")
       (eval-file (concatenate 'string "~/.local/share/filescript/" file ".fscript")))
      ((equal mode "local")
       (eval-file file)) 
      (t (progn 
           (format t "Error: Invalid mode~%")
           (print-documentation))))))
