;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-intermediate-lambda-reader.ss" "lang")((modname itunes-struct) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #f #t none #f () #f)))
(require 2htdp/itunes)
(require 2htdp/batch-io)
(require 2htdp/abstraction)
;==========================

; An LTracks is one of:
; – '()
; – (cons Track LTracks)

(define ITUNES-LOCATION "itunes.xml")


;-----------------------------------------------------------
; Date
;-----------------------------------------------------------
; Any Any Any Any Any Any -> [Maybe Date]
; creates an instance of Date for legitimate inputs 
; otherwise it produces #false.
; (define (create-date y mo day h m s)
;   ...)

; Examples
(define d1 (create-date 2017 5 20 22 00 15))
(define d2 (create-date 1985 1 20 16 30 49))


;-----------------------------------------------------------
; Tracks
;-----------------------------------------------------------
; Any Any Any Any Any Any Any Any -> [Maybe Track]
; creates an instance of Track for legitimate inputs
; otherwise it produces #false.
; (define (create-track name artist album time
;                       track# added play# played)
;   ...)

; Examples
(define t1 (create-track "Bomb" "Bush" "Sixteen Stone" 202893
                         142 d1 1 d2))
(define t2 (create-track "In Bloom" "Nirvana" "Nevermind" 254955
                         116 d1 3 d2))
(define t3 (create-track "XXX" "Nirvana" "Nevermind2" 254955
                         116 d1 3 d2))


;-----------------------------------------------------------
; LTracks
;-----------------------------------------------------------

; An LTracks is one of:
; – '()
; – (cons Track LTracks)

; Examples
(define tl1 (list t1 t2))
(define tl2 (list t1 t2 t1 t3 t2))
(define itunes-tracks
  (read-itunes-as-tracks ITUNES-LOCATION))

;-----------------------------------------------------------

; LTrack -> Number
; Consumes an element of LTracks and produces the total amount of play time.
(check-expect (total-time tl1) (+ 202893 254955))

(define (total-time tl)
  (for/sum ([t tl])
    (track-time t)))


; LTracks -> [List-of Strings]
; Consumes an LTracks and produces the list of album titles as a List-of-strings.
(check-expect (select-all-album-titles tl1) (list "Sixteen Stone" "Nevermind"))
(check-expect (select-all-album-titles tl2)
              (list "Sixteen Stone" "Nevermind" "Sixteen Stone"
                    "Nevermind2" "Nevermind"))

(define (select-all-album-titles tl)
  (for/list ([t tl])
    (track-album t)))


; [List-of String] -> [List-of String]
; Consumes a List-of-strings and constructs one that contains
; every String from the given list exactly once.
(check-expect (create-set (list "foo")) (list "foo"))
(check-expect (create-set (list "foo" "foo")) (list "foo"))
(check-expect (create-set (list "foo" "bar" "foo" "bar" "flag"))
              (list "foo" "bar" "flag"))

(define (create-set ss)
  (foldr (lambda (s ss) (if (member? s ss) ss (cons s ss)))
         '() ss))


; String LTracks -> LTrack 
; Consumes the title of an album and an LTracks. It extracts from the latter
; the list of tracks that belong to the given album.
(check-expect (select-album "Sixteen Stone" tl1) (list t1))

(define (select-album title lt)
  (filter (lambda (t) (string=? (track-album t) title))
          lt))


; LTracks -> LTracks
; The function consumes an element of LTracks. It produce a list of LTracks,
; one per album. Each album is uniquely identified by its title
; and shows up in the result only once.
(check-expect (select-albums tl2) (list t1 t3 t2))

(define (select-albums tt)
  (local ((define unique-al-titles (create-set (select-all-album-titles tt))))
    ; -IN-
    (for/list ([al-title unique-al-titles])
      (first (select-album al-title tt)))))