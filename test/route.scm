(use-modules (guest test)
             (schingle route))

(define parse-params (@@ (schingle route) parse-params))

(define-test (schingle route parse-params)
  (assert-equal? (parse-params '(GET "a" "b" "c") '(GET "a" "b" "c")) '())
  (assert-equal? (parse-params '(GET "a" :b "c") '(GET "a" "b" "c")) '((:b . "b")))
  (assert-equal? (parse-params '(GET :a :b :c) '(GET "a" "b" "c"))
          '((:a . "a") (:b . "b") (:c . "c"))))

(define-test (schingle route parse-params-splat)
  (assert-equal? (parse-params '(GET "a" (*) "c") '(GET "a" "b" "c")) '((* . ("b"))))
  (assert-equal? (parse-params '(GET "a" (*) "c") '(GET "a" "b" "e" "c")) '((* . ("b/e"))))
  (assert-equal? (parse-params '(GET "a" (* ".x") "c") '(GET "a" "b.x" "c")) '((* . ("b"))))
  (assert-equal? (parse-params '(GET "schingle" (* ".scm")) '(GET "schingle" "test.scm"))
                 '((* . ("test"))))
  (assert-equal? (parse-params '(GET "a" (*) "b" (*) "d") '(GET "a" "c" "c" "b" "c" "d"))
                 '((* . ("c/c" "c"))))
  (assert-equal? (parse-params '(GET "c" (*) "c" (*) "c") '(GET "c" "c" "c" "c" "c" "c"))
          '((* . ("" "c/c/c")))))

(define splat-acons (@@ (schingle route) splat-acons))

(define-test (schingle route splat-acons)
  (assert-equal? (splat-acons '() '()) '((*)))
  (assert-equal? (splat-acons '("a") '((a . b) (b . c))) '((* "a") (a . b) (b . c)))
  (assert-equal? (splat-acons '(x) '((a . b) (* . (c)) (b . c))) '((a . b) (* . (x c)) (b . c))))

(define make-pathmap (@@ (schingle route) make-pathmap))
(define pathmap-ref (@@ (schingle route) pathmap-ref))

(define-test (schingle route pathmap)
  (assert-equal? (pathmap-ref #f '("a" "b") 'default) 'default)
  (assert-equal? (pathmap-ref (make-hash-table) '("a" "b") 'default) 'default)
  (assert-equal? (pathmap-ref (make-pathmap '("a" :b) 5) '("a" "b") 'default) 5)
  (assert-equal? (pathmap-ref (make-pathmap '("a" "c") 5) '("a" "b") 'default) 'default)
  (assert-equal? (pathmap-ref (make-pathmap '("a" "c") 5) '("a" "c" "d")) #f))

(define-test (schingle route pathmap-splat)
  (assert-equal? (pathmap-ref (make-pathmap '("a" (*) "b") 5) '("a" "b")) 5)
  (assert-equal? (pathmap-ref (make-pathmap '("a" ("y" * ".c") "b") 5) '("a" "yx.c" "b")) 5)
  (assert-equal? (pathmap-ref (make-pathmap '("a" (*) "b") 5) '("a" "c" "b")) 5)
  (assert-equal? (pathmap-ref (make-pathmap '("a" (*) "b") 5) '("a" "c" "d" "b")) 5)
  (assert-equal? (pathmap-ref (make-pathmap '("a" (*) "b") 5) '("a" "c" "d" "b")) 5)
  (assert-equal? (pathmap-ref (make-pathmap '("a" (*) "c" (*) "e") 5) '("a" "b" "c" "d" "e")) 5)
  (assert-equal? (pathmap-ref (make-pathmap '("schingle" (* ".scm")) 5) '("schingle" "test.scm")) 5)
  (assert-equal? (pathmap-ref (make-pathmap '("a" (*) "c" (*) "e") 5) '("a" "c" "c" "c" "c" "e")) 5))
