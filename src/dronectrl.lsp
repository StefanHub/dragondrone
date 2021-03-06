;;
;; newLISP Simple AR.Drone control "UI"
;;
;; Keys:
;; +, < :     Takeoff
;; #, > :     Landing
;; space:     Hover
;; cr:        Emergency
;; tab:       Bye
;; backspace: Reset watchdog
;; 0 - 9:     speed
;; a - z:     led animations
;; A - Z      flight animations
;;
;; Arrow keys:                             Arrow keys with FN key pressed:
;;           tilt fron                             go up
;;               ^                                   ^
;;               |                                   |
;; tilt left <---+---> tilt right      spin left <---+---> spin right
;;               |                                   |
;;               v                                   v
;;           tilt back                            go down
;;

(load "ncurses.lsp")
(load "drone.lsp")

;; loops internally until end of game
(define (drone-control)
	(while (!= (let (ch (get-key))
		(process-key ch))
			key-tab)))

;; initial speed (0..1.0)
(set 'speed 0.1)

(define (process-key key)
;	(println "process")
	(cond
		((= key key-up)
			(println "key up - tilt front")
			(drone-tilt-front speed))
		((= key key-down)
			(println "key down tilt back")
			(drone-tilt-back speed))
		((= key key-left)
			(println "key left - tilt left")
			(drone-tilt-left speed))
		((= key key-right)
			(println "key right - tilt right")
			(drone-tilt-right speed))
		((= key fn-key-up)
			(println "fn key up - up")
			(drone-up speed))
		((= key fn-key-down)
			(println "fn key down - down")
			(drone-down speed))
		((= key fn-key-left)
			(println "fn key left - spin left")
			(drone-spin-left speed))
		((= key fn-key-right)
			(println "fn key right - spin right")
			(drone-spin-right speed))
		((range? key key-0 key-9)
			(set 'speed (div (sub key key-0) 10))
			(println "speed " speed))
		((range? key key-a key-z)
			(letn ((an-ind (sub key key-a)) (anim (safe-nth an-ind led-anims)))
				(println "led animations: " anim)
				(drone-leds anim 2.0 5)))
		((range? key key-A key-Z)
			(letn ((flight-ind (sub key key-A)) (anim (safe-nth flight-ind flight-anims)))
				(println "flight animations: " anim)
				(drone-anim anim 5000)))
		((= key key-space)
			(println "hover")
			(drone-hover))
		((in? key '(key-lt key-plus))
			(println "take-off")
			(drone-init)
			(drone-max-altitude 2000)
			(drone-takeoff))
		((in? key '(key-gt key-hash))
			(println "land")
			(drone-land)
			(drone-stop))
		((= key key-cr)
			(println "emergency")
			(drone-emergency))
		((= key key-backspace)
			(println "reset watchdog")
			(drone-reset-wdg))
		((= key key-tab)
			(println "bye"))
		((println "undefined key: " key)))
	key)

(define (range? v lo hi)
	(and (>= v lo) (<= v hi)))

(define (safe-nth ind li)
	 (nth (max (min ind (sub (length li) 1)) 0) li))

(define (in? v li)
	(!= nil (dolist (x li (= (eval x) v)) nil)))

(s-log "drone control loaded")
