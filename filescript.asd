(defsystem "filescript"
  :components (
               (:module "src"
                :components 
                ((:file "main"))))
  :build-operation "program-op"
  :build-pathname "filescript"
  :entry-point "filescript::main")


