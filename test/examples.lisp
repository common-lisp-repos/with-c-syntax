(in-package #:with-c-syntax.test)

(defun w-c-s-hello-world ()
  (with-c-syntax ()
    format \( t \, "Hello, World!" \) \;
    ))

(test test-hello-world ()
  (let ((tmpstr (make-array 0 :element-type 'base-char
			    :fill-pointer 0 :adjustable t)))
    (with-output-to-string (*standard-output* tmpstr)
      (w-c-s-hello-world))
    (is (string= "Hello, World!" tmpstr))))

(defun w-c-s-add-const ()
  (with-c-syntax ()
    return 1 + 2 \;
    ))

(test test-add-const
  (is (= 3 (w-c-s-add-const))))

(defun w-c-s-add-args (x y)
  (with-c-syntax ()
    return x + y \;
    ))

(test test-add-args
  (is (= 3 (w-c-s-add-args 1 2))))

(defun w-c-s-while-loop (&aux (x 0))
  (with-c-syntax ()
    while \( x < 100 \)
      x ++ \;
    return x \;
    ))

(test test-while-loop
  (is (= 100 (w-c-s-while-loop))))
  
(defun w-c-s-for-loop ()
  (let ((i 0) (sum 0))
    (with-c-syntax ()
      for \( i = 0 \; i <= 100 \; ++ i \)
         sum += i \;
      )
    sum))

(test test-for-loop
  (is (= 5050 (w-c-s-for-loop))))

(defun w-c-s-loop-continue-break (&aux (i 0) (sum 0))
  (with-c-syntax ()
    for \( i = 0 \; i < 100 \; ++ i \) {
      if \( (oddp i) \)
        continue \;
      if \( i == 50 \)
        break \;
      sum += i \;
    }
    return sum \;
   ))

(test test-loop-continue-break
  (is (= 600 (w-c-s-loop-continue-break))))

(defun w-c-s-switch (x &aux (ret nil))
  (with-c-syntax ()
    switch \( x \) {
    case 1 \:
      (push 'case1 ret) \;
      break \;
    case 2 \:
      (push 'case2 ret) \;
      ;; fall-though
    case 3 \:
      (push 'case3 ret) \;
      break \;
    case 4 \:
      (push 'case4 ret) \;
      break \;
    default \:
      (push 'default ret) \;
    })
  (nreverse ret))

(test test-switch
  (is (equal '(case1) (w-c-s-switch 1)))
  (is (equal '(case2 case3) (w-c-s-switch 2)))
  (is (equal '(case3) (w-c-s-switch 3)))
  (is (equal '(case4) (w-c-s-switch 4)))
  (is (equal '(default) (w-c-s-switch 5))))

(defun w-c-s-goto (&aux (ret nil))
  (with-c-syntax ()
      goto d \;

    a \:
      push \( 'a \, ret \) \;

    b \:
      push \( 'b \, ret \) \;
      goto e \;

    c \:
      push \( 'c \, ret \) \;
      return nreverse \( ret \) \;

    d \:
      push \( 'd \, ret \) \;
      goto a \;  
    
    e \:
      push \( 'e \, ret \) \;
      goto c \;
    ))

(test test-goto
  (is (equal '(d a b e c) (w-c-s-goto))))

(defun w-c-s-pointer (xxx &aux z)
  (with-c-syntax ()
    z =  & xxx \;
    * z += 1 \;
    * z *= 2 \;
    return xxx \;
    ))

(test test-pointer
  (is (= 2 (w-c-s-pointer 0)))
  (is (= 4 (w-c-s-pointer 1)))
  (is (= 22 (w-c-s-pointer 10))))

(in-readtable with-c-syntax-readtable)  
(defun w-c-s-duff-device (to-seq from-seq cnt)
  (with-c-syntax ()
    #{
    int * to = & to-seq;
    int * from = & from-seq;

    int n = (cnt + 7) / 8;
    n = floor(n);           #| Lisp's CL:/ produces rational |#
    switch (cnt % 8) {
    case 0 :	do {	* to ++ = * from ++;
    case 7 :		* to ++ = * from ++;
    case 6 :		* to ++ = * from ++;
    case 5 :		* to ++ = * from ++;
    case 4 :		* to ++ = * from ++;
    case 3 :		* to ++ = * from ++;
    case 2 :		* to ++ = * from ++;
    case 1 :		* to ++ = * from ++;
      } while (-- n > 0);
    }
    }#)
  to-seq)

(test test-duff-device ()
  (let ((arr1 (make-array 20 :initial-element 1))
	(arr2 (make-array 20 :initial-element 2)))
    (w-c-s-duff-device arr1 arr2 10)
    (is (equalp #(2 2 2 2 2 2 2 2 2 2 1 1 1 1 1 1 1 1 1 1)
		arr1))))

(test test-auto-return
  (is (= 100 (with-c-syntax (:return :auto)
	       100 \;)))
  (is (= 1 (with-c-syntax (:return :auto)
	     int i = 1 \; i \;)))
  (is (= 3 (with-c-syntax (:return :auto)
	     1 \; 2 \; 3 \;)))
  
  ;; can be expanded, but does not works (`return' or other ways required.)
  (is (= 4 (with-c-syntax (:return :auto)
	     if \( 10 \) return 4 \;)))
  (is (= 5 (with-c-syntax (:return :auto)
	     ;; FIXME
	     ;; `nil' cannot be directly used, we must quote it..
	     if \( 'nil \) 4 \; else return 5 \;)))
  (is (eq (readtable-case *readtable*)
	  (with-c-syntax (:return :auto)
	    switch \( (readtable-case *readtable*) \) {
	    case :upcase \: return :upcase \;
	    case :downcase \: return :downcase \;
	    case :preserve \: return :preserve \;
	    case :invert \: return :invert \;
	    default \: return "unknown!" \;
	    })))
  (let ((tmp 0))
    (with-c-syntax (:return :auto)
      int i \;
      for \( i = 0 \; i <= 100 \; ++ i \)
      tmp += i \;
      )
    (is (= tmp 5050)))
  (is (= 5050
	 (with-c-syntax (:return :auto)
	   int i = 0 \, j = 0 \;
	   next_loop \:
	   if \( i > 100 \) return j \;
	   j += i \;
	   ++ i \;
	   goto next_loop \;))))

;;; TODO: add new examples!
