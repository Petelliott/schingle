(use-modules (schingle template)
             (sxml simple))

(define pcons (@@ (schingle template) pcons))
(define-test (schingle template pcons)
  (assert-equal? (pcons '()) '())
  (assert-equal? (pcons '() '(1 . 2) '(2 . 3)) '((2 . 3) (1 . 2)))
  (assert-equal? (pcons '() '(1 . 2) '(2 . 3) '(4 . 5))
          '((4 . 5) (2 . 3) (1 . 2))))

(define bind-tag (@@ (schingle template) bind-tag))
(bind-tag 'a 5)
(bind-tag 'b (lambda (body) body))
(define-test (schingle template bind-tag)
  (assert-equal? (tag-ref 'a) 5)
  (assert (procedure? (tag-ref 'b)))
  (assert-equal? (tag-ref 'c) #f))

(define-tag d 6)
(define-tag (e body) body)
(define-test (schingle template define-tag)
  (assert-equal? (tag-ref 'd) 6)
  (assert (procedure? (tag-ref 'e)))
  (assert-equal? (tag-ref 'f) #f))

(define-test (schingle template tag-let)
  (tag-let ((g 5))
    (assert-equal? (tag-ref 'g) 5)
    (assert-equal? (tag-ref 'h) #f))
  (assert-equal? (tag-ref 'a) 5)
  (tag-let ((a 6))
    (assert-equal? (tag-ref 'a) 6))
  (assert-equal? (tag-ref 'a) 5))


(define-tag tag1 52)
(define-test (schingle template apply-template-val)
  (assert-equal? (apply-template (xml->sxml "<tag1/>")) '(*TOP* 52))
  (assert-equal? (apply-template (xml->sxml "<p><tag1/></p>")) '(*TOP* (p 52)))
  (assert-equal? (apply-template (xml->sxml "<p><tag1 a='b'/></p>"))
          '(*TOP* (p 52)))
  (assert-equal? (apply-template (xml->sxml "<p><tag1></tag1></p>"))
          '(*TOP* (p 52)))
  (tag-let ((tag1 53))
    (assert-equal? (apply-template (xml->sxml "<p><tag1 a='b'/></p>"))
            '(*TOP* (p 53))))
  (assert-equal? (apply-template (xml->sxml "<div a='b'/>"))
          '(*TOP* (div (@ (a "b"))))))

(define-tag (tag2 body . rest) (list body rest))
(define-test (schingle template apply-template-fn)
  (assert-equal? (apply-template (xml->sxml "<tag2/>")) '(*TOP* (() ())))
  (assert-equal? (apply-template (xml->sxml "<p><tag2/></p>")) '(*TOP* (p (() ()))))
  (assert-equal? (apply-template (xml->sxml "<p><tag2 a='b' c='d'/></p>"))
          '(*TOP* (p (() (#:c "d" #:a "b")))))
  (assert-equal? (apply-template (xml->sxml "<p><tag2>hello</tag2></p>"))
          '(*TOP* (p (("hello") ())))))

(define-tag z 5000)
(define-test (schingle template apply-template-file)
  (assert-equal? (apply-template-file "test/test.schtml")
          '(*TOP* (html "\n" (body "\n\n" (p 5000) "\n\n") "\n"))))
