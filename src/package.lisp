(in-package #:cl-user)

(defpackage #:with-c-syntax.syntax
  (:use) ; Saying I use no packages explicitly. (If omitted, it is implementation-dependent.)
  (:export
   ;; operators
   #:\,
   #:= #:*= #:/= #:%= #:+= #:-= #:<<= #:>>= #:&= #:^= #:\|=
   #:? #:\:
   #:\|\|
   #:&&
   #:\|
   #:^
   #:&
   #:== #:!=
   #:< #:> #:<= #:>=
   #:>> #:<<
   #:+ #:-
   #:* #:/ #:%
   #:\( #:\)
   #:++ #:-- #:|sizeof|
   #:& #:* #:+ #:- #:~ #:!
   #:[ #:] #:\. #:->
   ;; keywords
   #:\;
   #:|auto| #:|register| #:|static| #:|extern| #:|typedef|
   #:|void| #:|char| #:|short| #:|int| #:|long|
   #:|float| #:|double| #:|signed| #:|unsigned|
   #:|const| #:|volatile|
   #:|struct| #:|union|
   #:|enum|
   #:|...|
   #:|case| #:|default|
   #:{ #:}
   #:|if| #:|else| #:|switch|
   #:|while| #:|do| #:|for|
   #:|goto| #:|continue| #:|break| #:|return|
   ;; extensions
   #:|__lisp_type| #:|__offsetof|)
  (:documentation
   "Holds symbols denoting C operators and keywords."))

(defpackage #:with-c-syntax.core
  (:use #:cl #:with-c-syntax #:with-c-syntax.syntax)
  (:shadowing-import-from
   #:cl			      ; These CL symbols has same name with C.
   #:= #:/=  #:< #:> #:<= #:>=  #:+ #:- #:* #:/  #:++)
  (:use #:alexandria)
  (:import-from #:yacc
        	#:define-parser
                #:parse-with-lexer
		#:yacc-parse-error)
  (:import-from #:named-readtables
        	#:defreadtable)
  (:export
   ;; condition.lisp
   #:with-c-syntax-error
   #:with-c-syntax-warning
   ;; preprocessor.lisp
   #:build-libc-symbol-cache
   #:find-preprocessor-macro
   #:add-preprocessor-macro
   #:remove-preprocessor-macro
   #:define-preprocessor-constant
   #:define-preprocessor-function
   #:preprocessor
   ;; pseudo-pointer.lisp
   #:pseudo-pointer
   #:with-pseudo-pointer-scope
   #:invalidate-all-pseudo-pointers
   #:pseudo-pointer-pointable-p
   #:make-pseudo-pointer
   #:pseudo-pointer-dereference
   #:pseudo-pointer-invalidate
   ;; reader.lisp
   #:with-c-syntax-readtable
   #:*with-c-syntax-reader-level*
   #:*with-c-syntax-reader-case*
   ;; struct.lisp
   #:find-struct-spec
   #:add-struct-spec
   #:remove-struct-spec
   #:struct
   #:make-struct
   #:struct-member
   ;; typedef.lisp
   #:find-typedef
   #:add-typedef
   #:remove-typedef
   ;; with-c-syntax.lisp
   #:enum
   #:get-variadic-arguments
   #:with-c-syntax)
  (:documentation
   "with-c-syntax core package."))

(in-package #:with-c-syntax.core)

(eval-when (:compile-toplevel :load-toplevel :execute)
  (defun find-syntax-package ()
    "Returns the `WITH-C-SYNTAX.SYNTAX' package."
    (find-package '#:with-c-syntax.syntax)))
