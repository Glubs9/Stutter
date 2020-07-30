; helper functions start here ;

(define flip (lambda f (lambda a (lambda b (f b a))))) ; takes a function that takes two arguments and two arguments and then applies that function to those two arguments reversed ;
(define compose (lambda f1 (lambda f2 (lambda arg (f1 (f2 arg)))))) ; function composition ;
(define compose-two (lambda f1 (lambda f2 (lambda a1 (lambda a2 (f1 (f2 a1 a2))))))) ; function composition with two arguments ;

; this is equivalent to the bind function for the function monad ;
; although this is not standard in most stdlibs it comes up often enough in my experience to be useful to have ;
(define func-bind (lambda f1 (lambda f2 (lambda arg (f1 (f2 arg) arg)))))

(define assert (lambda bool (if bool true (raise assert_failed))))

; helper functions end here ;

; lambda calculus combinators start here ;
(define S (lambda x (lambda y (lambda z ((x z) (y z)))))) ; could be wrong ;
(define K (lambda x (lambda y x)))
(define I (S K S)) 
(define identity I) 
(define mockingbird (S I I)) ; returns yz everytime? ;
(define const K) 
(define ignore (K I))
(define apply (lambda f (lambda a (f a)))) ; useful for point free ;
(define hold (flip apply)) ; also called value ;
; lambda calculus combinators end here ;

; boolean functions here ;
(define or (lambda b1 (lambda b2 (if b1 true b2))))
(define and (lambda b1 (lambda b2 (if b1 b2 false))))
(define not (lambda b (if b false true)))
; bool functions end here ;

; number functions ;

(define negative?_rec (lambda x1 (lambda x2 (if (zero? x2) false
    (if (zero? x1) true
        (negative?_rec (increment x1) (decrement x2))))))) ; could be defined with > but for that to exist we need - and for that we need inverse and for that we need negative? to be defineda ;
(define negative? (lambda x (negative?_rec x x)))

; note could be defined with * -1 but we need this for addition which we need for multiplication ;
(define inverse (lambda x (if (zero? x) 0
	(if (negative? x)
		(increment (inverse (increment x)))
		(decrement (inverse (decrement x)))))))

(define plus_positive (lambda x1 (lambda x2 (if (zero? x2) x1
	(plus_positive (increment x1) (decrement x2))))))
(define + (lambda x1 (lambda x2 (if (negative? x2)
	(minus_positive x1 (inverse x2))
	(plus_positive x1 x2)))))

(define minus_positive (lambda x1 (lambda x2 (if (zero? x2) x1
	(minus_positive (decrement x1) (decrement x2))))))
(define - (lambda x1 (lambda x2 (if (negative? x2)
	(plus_positive x1 (inverse x2))
	(minus_positive x1 x2)))))

; * and / are very slow in this language ;
; multiply_rec only works on positive numbers ;
(define multiply_rec (lambda total (lambda original (lambda amount 
	(if (zero? amount) total
		(multiply_rec (+ total original) original (decrement amount))))))) ; the multiply algorithm could be improved ;
(define * (lambda x1 (lambda x2 
	(if (negative? x2)
		(inverse (multiply_rec 0 x1 (inverse x2)))
		(multiply_rec 0 x1 x2)))))

; division_rec only works on positive numbers ;
(define division_rec (lambda amount (lambda minus_accum (lambda minus_val 
	(let next (- minus_accum minus_val)
		(if (negative? next) amount
			(division_rec (increment amount) next minus_val)))))))
; division in this language is integers only due to ease of implementation ;
(define / (lambda dividend (lambda divisor
	(if (zero? dividend) (raise tried_to_divide_by_zero)
		(if (and (negative? dividend) (negative? divisor))
			(division_rec 0 (inverse dividend) (inverse divisor))
			(if (negative? dividend)
				(inverse (division_rec 0 (inverse dividend) divisor))
				(if (negative? divisor)
					(inverse (division_rec 0 dividend (inverse divisor)))
					(division_rec 0 dividend divisor))))))))

(define mod (lambda dividend (lambda divisor
	(let quotient (/ dividend divisor)
		(- dividend (* quotient divisor))))))

(define equals_rec (lambda x1 (lambda x2 
	(if (and (zero? x1) (zero? x2)) true
		(if (or (zero? x1) (zero? x2)) false
			(equals_rec (decrement x1) (decrement x2)))))))
(define = (lambda x1 (lambda x2
	(if (and (negative? x1) (negative? x2)) (equals_rec (inverse x1) (inverse x2))
		(if (or (negative? x1) (negative? x2)) false
			(equals_rec x1 x2))))))

(define != (compose-two not =))
(define <= (compose-two negative? (compose-two (decrement) -)))
(define >= (flip <= ))
(define > (compose-two not <=))
(define < (compose-two not >=)) ; could also be defined as (flip >) ;

(define odd? (lambda n
	(if (zero? n) false
		(even? (decrement n)))))
(define even? (lambda n
	(if (zero? n) true
		(odd? (decrement n)))))

; church encoding functions ;
; church numbers can only take one argument functions ;
(define church (lambda a (lambda f
	(if (zero? a) identity
		(compose f (church (decrement a) f))))))
(define unchurch (lambda f (f increment 0))) ; might be able to implement with hold ;
(define church* compose)
(define fast-mult (lambda n1 (lambda n2 (unchurch (church* (church n1) (church n2)))))) ; might be able to be defined pointfree ;
																						; maybe using s combinator ;
(define church^ apply)
(define church-succ (lambda num (lambda f (lambda inp (f (num f inp))))))
(define church+ (hold church-succ)) ; expands to (n1 church-succ n2) ;
; (define church-pred (lambda n (lambda f (lambda x (n
	(lambda g (lambda h (h (g f))))
	(lambda u x)
	(lambda u u)))))) ;
(define church-pred (lambda n (church (decrement (unchurch n))))) ; i could not get it working so this will have to do for now ;
; (define church- (lambda n1 (lambda n2 ((n1 church-pred) n2)))) fuck it nothing is working ;
; could define church-/ but tbh cannot be bothered anymore ;

; number functions end here ;

; maybe functions ;

(define just hold) ; i'm not too sure how to define just, hold is defined in lambda calculus section ;
(define nothing nothing) ; this is a redundant definition ;
(define extract-maybe (lambda mayb
	(if (str_eq nothing mayb)
		(raise tried_to_extract_nothing)
		(mayb identity)))) ; again not too sure how to work this ;

; maybe functions end here ;

; list functions start here ;

(define cons (lambda car_in (lambda cdr_in (lambda f (f car_in cdr_in))))) ; takes two arguments, holds them and calls a function with those values ;
(define car (hold const)) ; const and hold are defined in lambda calculus section ;
(define cdr (hold ignore)) ; ignore and hold are defined in lambda calculus section ;
(define caar (compose car car))
(define cadr (compose car cdr))
(define cdar (compose cdr car))
(define cddr (compose cdr cdr))
(define caddr (compose car cddr))
; last is defined below fold ;
; racket names for list manipulation ;
(define first car)
(define second cadr)
(define rest cdr)

(define odd-numbers (cons 1 (cons 3 (cons 5 (cons 7 (cons 9 (cons 11 (cons 13 (cons 15 end)))))))))
; example list ;

; fold is foldl ;
; fold is not useful for reconstructing lists because it doesn't send the end as thus the returned
array will not be properly constructed ;
; unless you handle that ;
(define foldl (lambda f (lambda accum (lambda list
	(let accum_next (f accum (car list)) (let tail (cdr list)
		(if (str_eq tail end) accum_next
			(foldl f accum_next tail))))))))

(define map (lambda f (lambda list 
	(let head (f (car list)) (let tail (cdr list)
		(if (str_eq tail end)
			(cons head end)
			(cons head (map f tail))))))))
; alternative defeintion of map that does not work
(define map-rec (lambda f (lambda head (lambda tail
	(if (str_eq tail end)
		(cons (f head) end)
		(cons (f head) (tail (map-rec f))))))))
(define map (lambda f (lambda list (list (map-rec f))))) ;

; might be able to implement map and filter with scan ;

; terrible but this is the only way i could get it to work ;
(define filter (lambda f (lambda list
	(let head (car list) (let tail (cdr list)
		(if (str_eq tail end)
			(if (f head) (cons head end) end)
			(if (f head) (cons head (filter f tail)) (filter f tail))))))))

; implement scan ;
(define scanl (lambda f (lambda accum (lambda list
	(let accum_next (f accum (car list)) (let tail (cdr list)
		(if (str_eq tail end) (cons accum_next end)
			(cons accum_next (scanl f accum_next tail)))))))))

(define last (foldl ignore end)) ; ignore is defined in lambda calculus section ;
(define init (lambda list
	(let tail (cdr list)
		(if (str_eq tail end) end
			(cons (car list) (init tail)))))) ; defined here because of its association with last ;

(define print-list (map print))
(define print-pair (lambda pair-in (begin 
	(print car-is)
	(print (car pair-in)) 
	(print cdr-is)
	(print (cdr pair-in)))))

; implement foldr using reverse ;
; implement reverse using tail and init ;

(define intersperse (lambda val (lambda list
	(let tail (cdr list) (let head (car list)
		(if (str_eq tail end)
			(cons head end)
			(cons head (cons val (intersperse val tail)))))))))

(define concat (lambda list1 (lambda list2
	(if (str_eq list1 end) list2 ( ; this is here because quick-sort calls concat with empty list ;
	(let tail (cdr list1) (let head (car list1)
		(if (str_eq tail end) 
			(cons head list2)
			(cons head (concat tail list2))))))))))

; implement list monad bind here ;

(define list-or (lambda list
	(let head (car list) (let tail (cdr list)
		(if head true
			(if (str_eq tail end) false
				(list-or tail)))))))

(define list-and (lambda list
	(let head (car list) (let tail (cdr list)
		(if head
			(if (str_eq tail end) true
				(list-and tail))
			false)))))

(define any? (compose-two list-or map))
(define all? (compose-two list-and map))

(define sum (foldl (+) 0))

(define product (foldl (*) 1))

(define max (lambda a1 (lambda a2 (if (> a1 a2) a1 a2))))
(define min (lambda a1 (lambda a2 (if (> a1 a2) a2 a1))))
(define maximum (lambda list (foldl max (car list) (cdr list)))) ; might be able to write this with function bind ;
(define minimum (lambda list (foldl min (car list) (cdr list)))) ; ^ ;

(define length-call (lambda accum (lambda _ (increment accum))))
(define length (lambda list
	(if (str_eq list end) 0
	(foldl length-call 0 list))))

(define take (lambda num (lambda list
	(let head (car list) (let next (decrement num)
		(if (zero? next)
			(cons head end)
			(cons head (take next (cdr list)))))))))

(define drop (lambda num (lambda list
	(let tail (cdr list) (let next (decrement num)
		(if (zero? next) tail
			(drop next tail)))))))

; take while does not work ;
(define take-while (lambda f (lambda list
	(let head (car list)
		(if (not (f head)) end
			(cons head (take-while (cdr list))))))))

; implement dropwhile ;
(define drop-while (lambda f (lambda list
	(let head (car list)
		(if (not (f head)) list
			(drop-while (cdr list)))))))

; only with numbers ;
; comparison operator should be passed ;
(define list-equals (lambda list1 (lambda list2
	(let head1 (car list1) (let head2 (car list2)
	(let tail1 (cdr list1) (let tail2 (cdr list2)
		(if (and (str_eq tail1 end) (str_eq tail2 end))
			(if (or (not (str_eq tail1 end)) (not (str_eq tail2 end)))
				false
				true)
			(if (!= head1 head2) false
				(list-equals tail1 tail2))))))))))

; pass comparison operator instead of = ;
; might be able to define with fold ;
(define element? (lambda val (lambda list
	(let tail (cdr list) (let head (car list)
		(if (= head val) true
			(if (str_eq tail end) false
				(elem? val tail))))))))
(define search element?) ; note: binary search is only faster than linear search for constant time
access arrays whereas with a cons list acessing elements is linear time therefore linear search is
faster even on a sorted list ;

(define not-elem? (compose-two not elem?))

; might be able to define with fold ;
; will error with index longer than the list ;
(define index (lambda pos (lambda list
	(let head (car list)
		(if (zero? pos) head
			(index (decrement pos) (cdr list)))))))

; maybe define element index ;
; passes in an element and list and returns the index of the first element that matches ;

; maybe define element indexes ;
; same as element index except it returns a list of all the matches ;

; define zip-with ;
(define zip-with (lambda f (lambda list1 (lambda list2
	(if (or (str_eq list1 end) (str_eq list2 end)) end
		(cons (f (car list1) (car list2)) (zip-with f (cdr list1) (cdr list2))))))))
(define zip-with-3 (lambda f (lambda l1 (lambda l2 (lambda l3
	(if (or (or (str_eq l1 end) (str_eq l2 end)) (str_eq l3 end)) end
		(cons (f (car l1) (car l2) (car l3)) (zip-with f (cdr l1) (cdr l2) (cdr l3)))))))))
; might be able to define a generic zip-with-n that gets sent a list of lists;

(define zip (zip-with cons))
(define zip3 (zip-with-3 (lambda a1 (lambda a2 (lambda a3 (cons a1 (cons a2 a3))))))) ; might be able to writ ethis better  ;
; maybe zip3-zip7 ;

; maybe define unzip ;

; maybe define nub ;

; potentially pass a comparison function ;
(define delete (lambda val (lambda list
	(let tail (cdr list) (let head (car list)
		(if (= val head) tail
		(if (str_eq tail end) list
			(cons head (delete val tail)))))))))

; sorting algorithms!!! ;
; maybe allow the user to pass a function for comparison ;
(define quick-sort (lambda list
	(if (str_eq list end) end
	(if (str_eq (cdr list) end) list
		(let head (car list) (let tail (cdr list) 
		(let less (filter (> head) tail)
		(let greater (filter (<= head) tail)
			(concat (quick-sort less) (concat
			(cons head end) (quick-sort greater)))))))))))

(define merge (lambda list1 (lambda list2
	(if (str_eq list1 end)
		list2
	(if (str_eq list2 end)
		list1 
	(let head1 (car list1) (let head2 (car list2) (let tail1 (cdr list1) (let tail2 (cdr list2)
		(if (< head1 head2)
			(cons head1 (merge tail1 list2))
			(cons head2 (merge list1 tail2))))))))))))

; implement merge sort using drop and take ;
(define merge-sort (lambda list
	(if (str_eq (cdr list) end) list
		(let middle (/ (length list) 2)
		(let first (merge-sort (take middle list))
		(let second (merge-sort (drop middle list))
			(merge first second)))))))

(define insert (lambda val (lambda list 
	(if (str_eq list end) (cons val end) ; this is here because insert-sort calls this with end as the list ;
	(let head (car list) (let tail (cdr list)
	(if (> head val) (cons val list)
		(if (str_eq tail end)
			(cons head (cons val end))
			(cons head (insert val tail))))))))))
(define insert-rec (lambda sorted (lambda unsorted
	(if (str_eq unsorted end) sorted
		(insert-rec (insert (car unsorted) sorted) (cdr unsorted))))))
(define insert-sort (insert-rec end))

(define bubble-rec (lambda list (lambda inp
	(if (str_eq end list) (cons inp end)
	(let head (car list) (let tail (cdr list)
		(cons (min head inp) (bubble-rec tail (max inp head)))))))))
(define bubble-sort (lambda list
	(let next (bubble-rec (cdr list) (car list))
	(if (list-equals next list) list
	(bubble-sort next)))))

; sorting algoirhtms end here ;

; list functions end here ;
