(in-package :with-c-syntax)

(defun test-all ()
  (test-stmt)
  (test-decl)
  (test-pointer)
  (test-trans)
  (test-examples)
  t)