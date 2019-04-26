(in-package #:with-c-syntax.libc-implementation)

;;; My hand-crafted codes assume 'C' locale.

;;; TODO
;;; - strcoll
;;; - strerror ; use osicat
;;; - strxfrm

(defun resize-string (string size)
  "Resize STRING to SIZE using `adjust-array' or `fill-pointer'.
This function is used for emulating C string truncation with NUL char."
  (declare (type string string)
	   (type fixnum size))
  (let ((str-size (length string)))
    (cond ((= str-size size)
	   string)			; return itself.
	  ((and (array-has-fill-pointer-p string)
		(< size (array-total-size string)))
	   (setf (fill-pointer string) size)
	   string)
	  (t
	   (adjust-array string size
			 :fill-pointer (if (array-has-fill-pointer-p string)
					   size))))))

(define-modify-macro resize-stringf (size)
  resize-string
  "Modify macro of `resize-string'")


(defun |strcpy| (dst src)
  "Emulates 'strcpy' of the C language."
  (resize-stringf dst (length src))
  (replace dst src))

(defun |strncpy| (dst src count)
  "Emulates 'strncpy' of the C language."
  (resize-stringf dst count)
  (replace dst src)
  ;; zero-filling of 'strncpy'.
  (let ((src-len (length src)))
    (when (> count src-len)
      (fill dst (code-char 0) :start src-len)))
  dst)

(defun |strcat| (dst src)
  "Emulates 'strcat' of the C language."
  (|strncat| dst src (length src)))

(defun |strncat| (dst src count)
  "Emulates 'strncat' of the C language."
  (let ((dst-len (length dst))
	(src-cat-len (min (length src) count) ))
    (resize-stringf dst (+ dst-len src-cat-len))
    (replace dst src :start1 dst-len :end2 src-cat-len)))

(defun |strlen| (str)
  "Emulates 'strlen' of the C language."
  (length str))

(defun strcmp* (str1 str1-len str2 str2-len)
  "Used by `|strcmp|' and `|strncmp|'"
  (let ((mismatch (string/= str1 str2 :end1 str1-len :end2 str2-len)))
    (cond
      ((null mismatch) 0)
      ((string< str1 str2 :start1 mismatch :start2 mismatch
		:end1 str1-len :end2 str2-len)
       (- (1+ mismatch))) ; I use `1+' to avoid confusion between 0 as equal and 0 as index
      (t		  ; `string>'
       (1+ mismatch)))))

(defun |strcmp| (str1 str2)
  "Emulates 'strcmp' of the C language."
  (strcmp* str1 nil str2 nil))

(defun |strncmp| (str1 str2 count)
  "Emulates 'strncmp' of the C language."
  (strcmp* str1 (min count (length str1))
	   str2 (min count (length str2))))

(defun make-trimed-vector (vector trim-position &optional (end (length vector) end-supplied-p))
  "Trims the head TRIM-POSITION elements of VECTOR, using `displaced-array'.
If END supplied, its tail is also trimed (using `displaced-array', too).

This function is used for emulating C string truncation with pointer movements."
  (check-type trim-position fixnum)
  (if (and (zerop trim-position)
	   (not end-supplied-p))
      vector
      (let ((new-length (- end trim-position))
	    (element-type (array-element-type vector)))
	(multiple-value-bind (displaced-to displaced-offset)
	    (array-displacement vector)
	  (if displaced-to
	      (make-array new-length
			  :element-type element-type
			  :displaced-to displaced-to
			  :displaced-index-offset (+ displaced-offset trim-position))
	      (make-array new-length
			  :element-type element-type
			  :displaced-to vector
			  :displaced-index-offset trim-position))))))

(define-modify-macro make-trimed-vectorf (trim-position)
  make-trimed-vector
  "Modify macro of `make-trimed-vector'")

(defun strchr* (str ch from-end)
  "Used by `|strchr|' and  `|strrchr|'"
  (let ((pos (position ch str :from-end from-end)))
    (cond (pos
	   (make-trimed-vector str pos))
	  ((eql ch (code-char 0))
	   "")	; C string has NUL in its end.
	  (t nil))))

(defun |strchr| (str ch)
  "Emulates 'strchr' of the C language."
  (strchr* str ch nil))

(defun |strrchr| (str ch)
  "Emulates 'strrchr' of the C language."
  (strchr* str ch t))

(defun strspn* (str accept)
  "Finds the position of the end of acceptable chars in STR.
If no such chars, return NIL."
  (flet ((acceptable-p (c) (find c accept)))
    (position-if-not #'acceptable-p str)))

(defun |strspn| (str accept)
  "Emulates 'strspn' of the C language."
  (or (strspn* str accept)
      (length str)))                    ; C's strspn requests it.

(defun strcspn* (str reject)
  "Finds the position of the end of rejected chars in STR.
If no such chars, return NIL."
  (flet ((rejected-p (c) (find c reject)))
    (position-if #'rejected-p str)))

(defun |strcspn| (str reject)
  "Emulates 'strcspn' of the C language."
  (or (strcspn* str reject)
      (length str)))                    ; C's strcspn requests it.

(defun |strpbrk| (str accept)
  "Emulates 'strpbrk' of the C language."
  (let ((pos (|strcspn| str accept)))
    (if (length= pos str)
	nil
	(make-trimed-vector str pos))))

(defun |strstr| (haystack needle)
  "Emulates 'strstr' of the C language."
  (if-let (i (search needle haystack))
    (make-trimed-vector haystack i)
    nil))


(defvar *strtok-target* ""
  "Used by |strtok|")

(defun |strtok| (str delim)
  "Emulates 'strtok' of the C language."
  (when str
    (setf *strtok-target* str))
  ;; find token-start
  (if-let ((token-start (strspn* *strtok-target* delim)))
    (make-trimed-vectorf *strtok-target* token-start)
    (progn
      (setf *strtok-target* "")
      (return-from |strtok| nil)))
  ;; find token-end
  (if-let ((token-end (strcspn* *strtok-target* delim)))
    (prog1 (make-trimed-vector *strtok-target* 0 token-end)
      (make-trimed-vectorf *strtok-target* token-end))
    (shiftf *strtok-target* "")))


;;; mem- family functions

(defun |memchr| (ptr ch count)
  "Emulates 'memchr' of the C language."
  (if-let (pos (position ch ptr :end (min count (length ptr))))
    (make-trimed-vector ptr pos)
    nil))

(defun |memcmp| (lhs rhs count &key (test #'eql) (predicate #'<) )
  "Emulates 'memcmp' of the C language."
  (let* ((lhs-len (length lhs))
	 (rhs-len (length rhs))
	 (mismatch (mismatch lhs rhs :test test
			     :end1 (min count lhs-len) :end2 (min count rhs-len))))
    (cond
      ((null mismatch) 0)
      ((< lhs-len mismatch) +1)
      ((< rhs-len mismatch) -1)
      ((funcall predicate (aref lhs mismatch) (aref rhs mismatch)) -1)
      (t +1))))

(defun |memset| (dest ch count)
  "Emulates 'memset' of the C language."
  (fill dest ch :end (min count (length dest))))

(defun |memcpy| (dest src count)
  "Emulates 'memcpy' of the C language."
  (replace dest src :end1 (min count (length dest))
	   :end2 (min count (length src))))

(defun |memmove| (dest src count)
  "Emulates 'memmove' of the C language."
  ;; `replace' does not fulfill 'memmove' requirements.
  ;; So, I copy the contents of SRC first.
  ;; 
  ;; It is quoted from http://www.lispworks.com/documentation/HyperSpec/Body/f_replac.htm
  ;; > However, if sequence-1 and sequence-2 are not the same, but the
  ;; > region being modified overlaps the region being copied from
  ;; > (perhaps because of shared list structure or displaced arrays),
  ;; > then after the replace operation the subsequence of sequence-1
  ;; > being modified will have unpredictable contents.
  (|memcpy| dest (copy-seq src) count))
