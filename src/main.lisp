(defpackage :filescript
  (:use :cl))

(in-package :filescript)

(defparameter *last* nil)
(defparameter *tpls* (make-hash-table :test #'equal))
(defparameter *content* nil)

(defun & (delimiter &rest parts)
  (reduce (lambda(x y) (concatenate 'string x delimiter y)) parts))
  
(defun copy (file newfile)
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
      (format t "Copied ~a -> ~a~%" file newfile))))

(defun cnf (file)
  (progn 
    (ensure-directories-exist file)
    (with-open-file (out file :direction :output :if-does-not-exist :create)
      (format t "Created ~a~%" file))
    (setf *last* file)))

(defun cnd (path)
  (ensure-directories-exist path)
  (format t "Created ~a~%" path))

(defun inc (file)
  (eval-file file))

(defun del (path)
  (progn
    (if (equal (file-namestring path) "") (uiop:delete-directory-tree path :validate t)
        (delete-file path))
    (format t "Deleted ~a~%" path)))

(defun move (file newfile)
  (rename-file file newfile)
  (setf *last* newfile)
  (format t "Renamed ~a -> ~a~%" file newfile))

(defun tpl (name)
  (let ((access (gethash name *tpls*)))
    (if access access 
        (progn
          (format t "~a: ~%" name)
          (let ((val (read-line)))
            (setf (gethash name *tpls*) val)
            val)))))

(defun add (&rest body)
  (append-to-file (apply #'str body) *last*)
  (format t "+ ~a~%" (apply #'str body)))

(defun str (&rest parts)
  (reduce (lambda(x y) (concatenate 'string x y)) parts))

(defun append-to-file (text file)
  (with-open-file (out file :direction :output :if-exists :append)
    (write-line text out)))


(defun get-command (line)
  (read-from-string line))

(defun get-body (line)
  (mapcar #'eval (cdr (get-objs line))))

(defun get-objs (line)
  (with-input-from-string (in line)
    (loop for form = (read in nil nil)
          while form
          collect form)))

(defun eval-line (line)
  (cond 
    ((char= (elt line 0) #\<) 
     (setf *content* t))
    ((char= (elt line 0) #\>)
     (setf *content* nil))
    (*content* (add line))
    ((char= (elt line 0) #\#)
     (format t "~a~%" line))
    (t (apply (get-command line) (get-body line)))))

(defun eval-file (filename)
  (with-open-file (in filename)
    (loop for line = (read-line in nil) while line do
          (if (equal line "") nil (eval-line line)))
    t))

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
