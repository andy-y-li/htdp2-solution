;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-intermediate-lambda-reader.ss" "lang")((modname ex292-sorted-check) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #f #t none #f () #f)))
; [X X -> Boolean] [NEList-of X] -> Boolean
; determine whether l is sorted according to cmp.

(check-expect (sorted? < '(1 2 3)) #true)
(check-expect (sorted? < '(2 1 3)) #false)

(define (sorted? cmp l)
  (cond [(or (empty? l) (empty? (rest l))) #true]
        [else (and (cmp (first l) (second l))
                   (sorted? cmp (rest l)))]))