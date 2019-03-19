(defsystem #:with-c-syntax-test
  :description "test for with-c-syntax."
  :license "WTFPL"
  :author "YOKOTA Yuki <y2q.actionman@gmail.com>"
  :pathname #.(make-pathname :directory '(:relative "test"))
  :depends-on (#:with-c-syntax)
  :components ((:file "package")
	       (:file "util" :depends-on ("package"))
               (:file "stmt" :depends-on ("util"))
	       (:file "decl" :depends-on ("util"))
               (:file "pointer" :depends-on ("util"))
	       (:file "trans" :depends-on ("util"))
	       (:file "wcs" :depends-on ("util"))
	       (:file "reader" :depends-on ("util"))
	       (:file "preprocessor" :depends-on ("util"))
	       (:file "examples" :depends-on ("util"))
	       (:file "all"
		:depends-on ("stmt" "decl" "pointer"
			     "trans" "wcs" "reader"
			     "preprocessor" "examples")))
  :perform (test-op (o s)
             (symbol-call '#:with-c-syntax.test
                          '#:test-all)))