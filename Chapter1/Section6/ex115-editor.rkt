;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-beginner-reader.ss" "lang")((modname ex115-editor) (read-case-sensitive #t) (teachpacks ((lib "image.rkt" "teachpack" "2htdp") (lib "universe.rkt" "teachpack" "2htdp"))) (htdp-settings #(#t write repeating-decimal #f #t none #f ((lib "image.rkt" "teachpack" "2htdp") (lib "universe.rkt" "teachpack" "2htdp")) #f)))
; String Position String -> String
; insert *is* at the *p* of *str*
; examples:
(check-expect (string-insert "Hello" 2 "!")
              (string-append (substring "Hello" 0 2)
                             "!"
                             (substring "Hello" 2)))

(define (string-insert str p is)
  (string-append (substring str 0 p) is (substring str p)))


; String Position -> String
; delete the character in front of the *p* in *str*
; examples:
(check-expect (string-delete "Hello" 2)
              (string-append (substring "Hello" 0 (- 2 1))
                             (substring "Hello" 2)))

(define (string-delete str p)
  (string-append (substring str 0 (- p 1))
                 (substring str p)))


; ---String module---

(define-struct editor [text pos])
; Editor = (make-editor String Number)
; interpretation (make-editor t p) means the text is
; (substring t 0 p) and (substring t p), with cursor
; displayed between the two part.

(define ed-n (make-editor "Hello world!" 5))
(define ed-l (make-editor "Empty right side."
                          (string-length "Empty right side.")))
(define ed-r (make-editor "Empty left side." 0))
(define long-ed (make-editor "1234567890123456789012"
                             (string-length "1234567890123456789012")))


; KeyEvents
; - 1-String: insert it into editor-pre
; - "\b": delete one string in the left of cursor, if any
; - "left" and "right": move a character from pre to post, vice
; versa, if any.


; graphic constants
(define CURSOR (rectangle 1 20 "solid" "red"))
(define BKG (empty-scene 200 20))
(define SIZE 16)
(define COLOR "black")


; Editor -> Image
; determine how to display the text.
; examples:
(check-expect (text-warp ed-n)
              (beside (text (substring (editor-text ed-n) 0 (editor-pos ed-n)) SIZE COLOR)
                      CURSOR
                      (text (substring (editor-text ed-n) (editor-pos ed-n)) SIZE COLOR)))

(define (text-warp ed)
  (beside (text (substring (editor-text ed) 0 (editor-pos ed)) SIZE COLOR)
          CURSOR
          (text (substring (editor-text ed) (editor-pos ed)) SIZE COLOR)))


; Editor -> Image
; render the text part of Editor. The text seperate into 2
; parts, the left is (substring t 0 p); the right is
; (substring t p).
; examples:
(check-expect (render ed-n)
              (overlay/align "left" "center" (text-warp ed-n) BKG))
(check-expect (render ed-l)
              (overlay/align "left" "center" (text-warp ed-l) BKG))
(check-expect (render ed-r)
              (overlay/align "left" "center" (text-warp ed-r) BKG))

(define (render ed)
  (overlay/align "left" "center" (text-warp ed) BKG))


; Editor -> Boolean
; determine weather a Editor e is to change.
; If the text is longer than the WIDTH of BKG,
; then return #f; else return #t.
; examples：
(check-expect (normal-text? ed-n) #t)
(check-expect (normal-text? long-ed) #f)

(define (normal-text? ed)
  (if (>= (image-width (text-warp (make-editor (string-append (editor-text ed) " ")
                                               (editor-pos ed))))
         (image-width BKG))
      #f
      #t))


; Editor -> Editor
; consume a KeyEvent ke and a Editor ed.
; the ke may change the ed
; if ke is 1-String exclude "\t" "\r" "\b" etc., insert into
; the front of pos of ed (unless string is longer than the width of BKG)
; if ke is "\b", delete a character in front of pos of ed (unless pos is 0)
; if ke is "left" or "right", then add/sub 1 to pos of ed (unless pos is at the relative end)
; examples:
; normal example, cursor is in the string.
(check-expect (edit ed-n " ")
              (make-editor (string-insert (editor-text ed-n)
                                          (editor-pos ed-n)
                                          " ")
                           (+ (editor-pos ed-n) 1)))
(check-expect (edit ed-n "\b")
              (make-editor (string-delete (editor-text ed-n)
                                          (editor-pos ed-n))
                           (- (editor-pos ed-n) 1)))
(check-expect (edit ed-n "\n") ed-n)
(check-expect (edit ed-n "left")
              (make-editor (editor-text ed-n) (- (editor-pos ed-n) 1)))
(check-expect (edit ed-n "right")
              (make-editor (editor-text ed-n) (+ (editor-pos ed-n) 1)))
(check-expect (edit ed-n "up") ed-n)

; special example, cursor is at the right end of string
(check-expect (edit ed-l " ")
              (make-editor (string-insert (editor-text ed-l)
                                          (editor-pos ed-l)
                                          " ")
                           (+ (editor-pos ed-l) 1)))
(check-expect (edit ed-l "\b")
              (make-editor (string-delete (editor-text ed-l)
                                          (editor-pos ed-l))
                           (- (editor-pos ed-l) 1)))
(check-expect (edit ed-l "\n") ed-l)
(check-expect (edit ed-l "left")
              (make-editor (editor-text ed-l) (- (editor-pos ed-l) 1)))
(check-expect (edit ed-l "right") ed-l)
(check-expect (edit ed-l "up") ed-l)

; special example, cursor is at the left end of string
(check-expect (edit ed-r " ")
              (make-editor (string-insert (editor-text ed-r)
                                          (editor-pos ed-r)
                                          " ")
                           (+ (editor-pos ed-r) 1)))
(check-expect (edit ed-r "\b") ed-r)
(check-expect (edit ed-r "\n") ed-r)
(check-expect (edit ed-r "left") ed-r)
(check-expect (edit ed-r "right")
              (make-editor (editor-text ed-r) (+ (editor-pos ed-r) 1)))
(check-expect (edit ed-r "up") ed-r)

; special example, the string is longer than the width of BKG
(check-expect (edit long-ed " ") long-ed)
(check-expect (edit long-ed "\b")
              (make-editor (string-delete (editor-text long-ed)
                                          (editor-pos long-ed))
                           (- (editor-pos long-ed) 1)))
(check-expect (edit long-ed "\n") long-ed)
(check-expect (edit long-ed "left")
              (make-editor (editor-text long-ed) (- (editor-pos long-ed) 1)))
(check-expect (edit long-ed "right") long-ed)
(check-expect (edit long-ed "up") long-ed)

(define (edit ed ke)
  (cond [(= (string-length ke) 1)
         (cond [(and (string=? ke "\b") (< 0 (editor-pos ed)))
                (make-editor (string-delete (editor-text ed)
                                            (editor-pos ed))
                             (- (editor-pos ed) 1))]
               [(and (<= 32 (string->int ke) 126) (normal-text? ed))
                ; 使用ASCII码判断是否为可显示字符，然后打印出来
                ; use ASCII to predict weather the character is printable character.
                (make-editor (string-insert (editor-text ed)
                                            (editor-pos ed)
                                            ke)
                             (+ (editor-pos ed) 1))]
               [else ed])]
        [(and (string=? "left" ke) (< 0 (editor-pos ed)))
         (make-editor (editor-text ed)
                      (- (editor-pos ed) 1))]
        [(and (string=? "right" ke) (> (string-length (editor-text ed)) (editor-pos ed)))
         (make-editor (editor-text ed)
                      (+ (editor-pos ed) 1))]
        [else ed]))


; String -> launch program
; comsume a string that represent the initial state of the world
(define (run text)
  (big-bang (make-editor text 0)
            [to-draw render]
            [on-key edit]
            [check-with editor?]))

(run "")
