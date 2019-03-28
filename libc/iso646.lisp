(in-package #:with-c-syntax.libc)

(eval-when (:load-toplevel :execute)
(add-preprocessor-macro "and" 'with-c-syntax.core::&&)
(add-preprocessor-macro "and_eq" 'with-c-syntax.core::&=)
(add-preprocessor-macro "bitand" 'with-c-syntax.core::&)
(add-preprocessor-macro "bitor" 'with-c-syntax.core::\|)
(add-preprocessor-macro "compl" 'with-c-syntax.core::~)
(add-preprocessor-macro "not" 'with-c-syntax.core::!)
(add-preprocessor-macro "not_eq" 'with-c-syntax.core::!=)
(add-preprocessor-macro "or" 'with-c-syntax.core::\|\|)
(add-preprocessor-macro "or_eq" 'with-c-syntax.core::\|=)
(add-preprocessor-macro "xor" 'with-c-syntax.core::^)
(add-preprocessor-macro "xor_eq" 'with-c-syntax.core::^=)
)
