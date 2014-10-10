(in-package #:with-c-syntax.stdlib)

(eval-when (:load-toplevel :execute)
(define-preprocessor-macro "and" 'with-c-syntax::&&)
(define-preprocessor-macro "and_eq" 'with-c-syntax::&=)
(define-preprocessor-macro "bitand" 'with-c-syntax::&)
(define-preprocessor-macro "bitor" 'with-c-syntax::\|)
(define-preprocessor-macro "compl" 'with-c-syntax::~)
(define-preprocessor-macro "not" 'with-c-syntax::!)
(define-preprocessor-macro "not_eq" 'with-c-syntax::!=)
(define-preprocessor-macro "or" 'with-c-syntax::\|\|)
(define-preprocessor-macro "or_eq" 'with-c-syntax::\|=)
(define-preprocessor-macro "xor" 'with-c-syntax::^)
(define-preprocessor-macro "xor_eq" 'with-c-syntax::^=)
)
