(defpackage :filescript
  (:use :cl)
  (:export #:main))

(in-package :filescript)

(defparameter *last* nil)
(defparameter *tpls* (make-hash-table :test #'equal))
(defparameter *content* nil)

(defun & (delimiter &rest parts)
  (reduce (lambda(x y) (concatenate 'string x delimiter y)) parts))
  
(defun copy (line)
  (let*
    ((strs (uiop:split-string line))
     (file (car strs))
     (newfile (second strs))
     (temp nil))
    (progn
      (with-open-file (in file)
        (loop for line = (read-line in nil) while line do
              (push line temp)))
      (ensure-directories-exist newfile)
      (with-open-file (out newfile :direction :output :if-exists :supersede)
        (loop for line in (reverse temp) do
              (format out "~a~%" line)))
      (format t "Copied ~a -> ~a~%" file newfile))))

(defun newfile (file)
  (progn 
    (ensure-directories-exist file)
    (with-open-file (out file :direction :output :if-does-not-exist :create)
      (format t "Created ~a~%" file))
    (setf *last* file)))

(defun newdir (path)
  (ensure-directories-exist path)
  (format t "Created ~a~%" path))

(defun include (file)
  (eval-file file))

(defun select (file)
  (setf *last* file)
  (format t "Editing ~a~%" file))

(defun delpath (path)
  (progn
    (if (equal (file-namestring path) "") (uiop:delete-directory-tree path :validate t)
        (delete-file path))
    (format t "Deleted ~a~%" path)))

(defun move (line)
  (let* ((strs (uiop:split-string line))
        (file (car strs))
        (newfile (second strs)))
    (rename-file file newfile)
    (setf *last* newfile)
    (format t "Renamed ~a -> ~a~%" file newfile)))

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

(defun addstr (body)
  (let* ((objs (get-objs body))
        (expanded (mapcar
          (lambda (x)
            (if (stringp x)
                x
                (replace-var (string x))))
          objs))
        (line
          (reduce (lambda(x y) (concatenate 'string x y)) expanded)))
    (append-to-file line *last*)
    (format t "+ ~a~%" line)))
            

(defun str (&rest parts)
  (reduce (lambda(x y) (concatenate 'string x y)) parts))

(defun append-to-file (text file)
  (with-open-file (out file :direction :output :if-exists :append)
    (write-line text out)))


(defun get-command (line)
  (read-from-string line))

(defun get-body (line)
  (let ((fst (multiple-value-list (read-from-string line))))
    (subseq line (second fst))))

(defun get-objs (line)
  (with-input-from-string (in line)
    (loop for form = (read in nil nil)
          while form
          collect form)))

(defun expand-var (line)
  (cond
    ((not (position #\< line))
     line)
    (t (expand-var (replace-var line)))))

(defun replace-var (line)
  (let* (
         (opening (position #\< line))
         (closing (position #\> line))
         (tpl-name (subseq line (1+ opening) closing)))
    (concatenate
      'string
      (subseq line 0 opening)
      (tpl tpl-name)
      (subseq line (1+ closing)))))

(defun eval-line (line)
  (cond 
    ((char= (elt line 0) #\<) 
     (setf *content* t))
    ((char= (elt line 0) #\>)
     (setf *content* nil))
    (*content* (add line))
    ((char= (elt line 0) #\#)
     (format t "~a~%" line))
    ((equal (get-command line) 'addstr) 
     (funcall (get-command line) (get-body line)))
    (t (funcall (get-command line) (expand-var (get-body line))))))

(defun eval-file (filename)
  (with-open-file (in filename)
    (loop for line = (read-line in nil) while line do
          (if (equal line "") nil (eval-line line)))
    t))

(defun main ()
  (let* (
         (args (uiop:command-line-arguments))
         (file (first args)))
    (setf *package* (find-package 'filescript))
    (eval-file file)))
