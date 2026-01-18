(pushnew (uiop:getcwd) ql:*local-project-directories*)
(ql:quickload :filescript)
(asdf:make :filescript)
