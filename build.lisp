(load "file.lisp")
(sb-ext:save-lisp-and-die "filescript" :toplevel #'main :executable t)
