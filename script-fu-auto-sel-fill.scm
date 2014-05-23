;script-fu-auto-sel-fill.scm
;
;(c) 2014 mk.
;License Mit license


(define end-flg #f)
(define msg-flg #t)
(define chg-tgt-flg #f)
(define chg-tgt-buff 0)
(define start-flg #t)

(define cadr (lambda (x) (car (cdr x))))
(define zero? (lambda (x) (eqv? x 0)))
(define gm (lambda (atom) (gimp-message (atom->string atom)))) 
(define get-img (lambda n
  (vector-ref (cadr (gimp-image-list)) (if (null? n) 0 (car n)))))
(define vector->list (lambda (vec)
	(let loop ((ls '()) (len (- (vector-length vec) 1)))
		(if (< len 0)
				ls
				(loop (cons (vector-ref vec len) ls) (- len 1))))))
(define max (lambda (ls)
  (let loop ((mx (car ls)) (tmp (cdr ls)))
		(if (null? tmp)
				mx
				(let ((t (car tmp)))
					(loop (if (< mx t) t mx) (cdr tmp)))))))
(define vector-max-rec (lambda (len mx tmp)
	(if (<= len 0) 
			mx 
			(vector-max-rec	(- len 1) 
											(if (> tmp mx) tmp mx) 
											(vector-ref vec (- len 1))))))
(define vector-max (lambda (vec)
  (let ((len (- (vector-length vec) 1))) 
		(vector-max-rec len 0 (vector-ref vec len)))))

(define map (lambda (fun ls)
    (if (null? ls)
        '()
				(cons (fun (car ls)) (map fun (cdr ls))))))
(define for-each (lambda (fun ls)
  (if (null? ls)
			#t
			(let ((x (car ls)))
				(fun x)
				(for-each fun (cdr ls))))))

(macro when (lambda (x)
  (let ((arg1 (car (cdr x))) (arg2 (cdr (cdr x))))
    (if arg1 (cons 'begin arg2)))))

(define (layers-for-each fun . lyrs)
	(let ((lyrs (if (null? lyrs)
									(gimp-image-get-layers 
									  (vector-ref (cadr (gimp-image-list)) 0))
									(car lyrs))))
		(let for-each-rec ((fun fun) (lyrs lyrs))
			(if (<= (car lyrs) 0) 
					'end
					(let ((l (- (car lyrs) 1))) 
						(fun (vector-ref (cadr lyrs) l) 
						(for-each-rec fun (set-car! lyrs l))))))))

(define (fill lyr)
	(let ((img (get-img)))
		(gimp-image-undo-group-start img)
		(gimp-edit-fill lyr 0)
		(gimp-selection-none img)
		(gimp-displays-flush)
		(gimp-image-undo-group-end img)))

(define (get-next-layer img active) 
  (let ((res (gimp-image-get-layers img)))
  (let ((num (car res))
				(layers (cadr res))
				(ls '()))
		(let loop ((i 0) (len (- (vector-length layers) 1))) 
			(if (eqv? active (vector-ref layers i)) 
				  (if (not (eqv? i len)) (cons num (cons (vector-ref layers (+ i 1)) ls)))
					(loop (+ i 1) len))))))

(define (vector-cmp lyr1 lyr2)
	(let loop ((len (- (vector-length lyr1) 1)))
		(if (< len 0)
				#t
				(if (not (eqv? (vector-ref lyr1 len) (vector-ref lyr2 len)))
						#f
						(loop (- len 1))))))

(define (sfp-extract-line-drawing)
	(let ((img (vector-ref (cadr (gimp-image-list)) 0)))
		(let ((lyr (car (gimp-image-get-active-layer img))))
			(gimp-image-undo-group-start img)
	    (gimp-image-select-color img 0 lyr '(255 255 255))
      (gimp-edit-clear lyr)
			(gimp-selection-none img)
			(gimp-image-undo-group-end img)
			(gimp-displays-flush))))

(define (asfsrec img sel trg num layers btn btn2)
	(if (zero? (car (gimp-item-get-visible btn)))
			(begin (set! end-flg #t) (set! start-flg #t)))
	(if (zero? (car (gimp-item-get-visible btn2)))
			(begin (set! chg-tgt-flg #t))
			(set! chg-tgt-flg #f))
	(define tmp (gimp-image-get-layers img))

	(define tmp-num (car tmp))
	(define tmp-layers (cadr tmp))

	(if (< (- tmp-num 3) (car (gimp-image-get-item-position img sel)))
		(let ((tmp-lyr (car (gimp-layer-new img (car (gimp-image-width img))
															 (car (gimp-image-height img))
																		1 "tmp" 100 0)))) 
			(gimp-image-raise-item img sel) 
			(gimp-image-insert-layer img tmp-lyr 0 -1)
			(gimp-image-lower-item img tmp-lyr)))

	(if (not chg-tgt-flg)
			(if (not start-flg) (begin (gimp-item-set-name btn2 "LATEST")(set! trg (max (vector->list (cadr (gimp-image-get-layers img)))))) (gimp-message (atom->string trg)))
			(begin 
				(gimp-item-set-name btn2 "LOWER")
				(define t (cadr (get-next-layer img (car (gimp-image-get-active-layer img)))))
				(set! trg t)))

	(if (not (eqv? num tmp-num))
		(begin 
			(set! num tmp-num)
			(set! trg (car (gimp-image-get-active-layer img)))
			(gimp-image-set-active-layer img sel)
			(set! start-flg #f)))

  (if (not (vector-cmp layers tmp-layers))
			(begin (gimp-image-set-active-layer img sel)
				(set! layers tmp-layers)))

	(usleep 100000)
	(if msg-flg
			(begin 
				(gimp-message "asf is running...")
				(set! msg-flg #f))
			(set! msg-flg #t))
	(if end-flg
			(begin (gimp-image-remove-layer img btn)
				(gimp-image-remove-layer img btn2)
				(gimp-message "asf stopped") (gimp-displays-flush))
			(if (= (car (gimp-selection-is-empty img)) 0)
					(begin 
						(gimp-image-undo-group-start img)
						(gimp-selection-grow img 1)
						(gimp-edit-fill trg 0)
						(gimp-selection-clear img)
					  (gimp-displays-flush)
						(gimp-image-undo-group-end img)
						(asfsrec img sel trg num layers btn btn2))
					(asfsrec img sel trg num layers btn btn2))))

(tracing TRUE)
(define (script-fu-auto-sel-fill)
	(if end-flg (set! end-flg #f))
	(let ((img (vector-ref (cadr (gimp-image-list)) 0)))
		(if (eqv? (car (gimp-selection-is-empty img)) 0)
			(gimp-selection-none img))
 	  (let ((s (car (gimp-image-get-active-layer img))))
			(define new-btn (car (gimp-layer-new img 
													 (car (gimp-image-width img))
													 (car (gimp-image-height img))
													 0 "STOP" 100 0)))
			(gimp-image-insert-layer img new-btn 0 0)
			(gimp-image-lower-item-to-bottom img new-btn)
			(gimp-edit-fill new-btn 2)
			(define new-btn2 (car (gimp-layer-copy new-btn FALSE)))
			(gimp-image-insert-layer img new-btn2 0 -1)
			(gimp-item-set-name new-btn2 "change")
			(gimp-displays-flush)
			(gimp-image-set-active-layer img s)

			(let* ((res (get-next-layer img s))
						(t (cadr res))
						(num (car res)))

			(asfsrec img s t num (cadr (gimp-image-get-layers img)) new-btn new-btn2)))))
(tracing FALSE)

(define (script-fu-auto-sel-fill-stop)
	(set! end-flg #t))
(define (script-fu-asf-change-target)
	(script-fu-auto-sel-fill-stop)
	(script-fu-auto-sel-fill))
(script-fu-register "script-fu-asf-change-target" "script-fu-asf-change-target" "." "morinaga" "(c) morinaga kazuma 2013." "July 13, 2013" "")
(script-fu-menu-register "script-fu-asf-change-target" "<Image>/Filters")
(script-fu-register "sfp-extract-line-drawing" "sfp-extract-line-drawing" "." "morinaga" "(c) morinaga kazuma 2013." "July 13, 2013" "")
(script-fu-menu-register "sfp-extract-line-drawing" "<Image>/Filters")
(script-fu-register "script-fu-auto-sel-fill" "script-fu-auto-sel-fill" "Fill the target layer of specified image." "morinaga" "(c) morinaga kazuma 2013." "July 13, 2013" "")
(script-fu-menu-register "script-fu-auto-sel-fill" "<Image>/Filters")
