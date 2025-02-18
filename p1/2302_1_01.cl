;; Javier Martinez Rubio javier.martinezrubio@estudiante.uam.es e357532
;; Jorge Santisteban Rivas jorge.santisteban@estudiante.uam.es e360104
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; EJERCICIO 1
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defun formula-dst (x y prod-esc)
  (- 1 (/ (funcall prod-esc x y)
             (* (sqrt(funcall prod-esc x x))
                (sqrt(funcall prod-esc y y))))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; producto-escalar-rec (x y)
;;; Calcula el producto escalar de forma recursiva
;;; Se asume que los dos vectores de entrada tienen la misma longitud.
;;;
;;; INPUT: x: vector, representado como una lista
;;;         y: vector, representado como una lista
;;; OUTPUT: producto escalar entre x e y
;;;

(defun prod-esc-rec (x y)
  (if (or (null x) (null y))
    0
    (+ (* (first x) (first y))
       (prod-esc-rec (rest x) (rest y)))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; cosine-distance-rec (x y)
;;; Calcula la distancia coseno de un vector de forma recursiva
;;; Se asume que los dos vectores de entrada tienen la misma longitud.
;;;
;;; INPUT: x: vector, representado como una lista
;;;         y: vector, representado como una lista
;;; OUTPUT: distancia coseno entre x e y
;;;
(defun cosine-distance-rec (x y)
  (cond ((= 0 (* (prod-esc-rec x x) (prod-esc-rec y y))) 0)
        (t (formula-dst x y #'prod-esc-rec))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; producto-escalar-mapcar (x y)
;;; Calcula el producto escalar usando mapcar
;;; Se asume que los dos vectores de entrada tienen la misma longitud.
;;;
;;; INPUT: x: vector, representado como una lista
;;;         y: vector, representado como una lista
;;; OUTPUT: producto escalar entre x e y
;;;

(defun prod-esc-mapcar (x y)
  (if (or (null x) (null y))
  0
  (apply #'+ (mapcar #'* x y))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; cosine-distance-mapcar
;;; Calcula la distancia coseno de un vector usando mapcar
;;; Se asume que los dos vectores de entrada tienen la misma longitud.
;;;
;;; INPUT:  x: vector, representado como una lista
;;;         y: vector, representado como una lista
;;; OUTPUT: distancia coseno entre x e y
;;;

(defun cosine-distance-mapcar (x y)
  (cond ((= 0 (* (prod-esc-mapcar x x) (prod-esc-mapcar y y))) 0)
        (t (formula-dst x y #'prod-esc-mapcar))))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; order-lst-vectors
;;; Ordena las listas segun su nivel de confianza
;;; INPUT:  vector-ref: vector que representa a una categoria,
;;;                 representado como una lista
;;;         vector-insert: dupla con el vector a insertary su distancia, ya calculada
;;;         ord-lst-of-vectors: nuevo vector de vectores ordenados
;;; OUTPUT: Vectores cuya semejanza con respecto a la
;;;         categoria es superior al nivel de confianza ,
;;;         ordenados
;;;


(defun order-lst-vectors(vector-ref vector-insert ord-lst-of-vectors)
  (cond ((null  ord-lst-of-vectors) (cons (second vector-insert) ord-lst-of-vectors))
        ((< (first vector-insert)
            (cosine-distance-mapcar vector-ref (first ord-lst-of-vectors)))
         (cons (second vector-insert) ord-lst-of-vectors))
        (t (cons (first ord-lst-of-vectors)
                 (order-lst-vectors vector-ref vector-insert (rest ord-lst-of-vectors))))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; order-vectors-cosine-distance
;;; Devuelve aquellos vectores similares a una categoria
;;; INPUT:  vector: vector que representa a una categoria,
;;;                 representado como una lista
;;;         lst-of-vectors vector de vectores
;;;         confidence-level: Nivel de confianza (parametro opcional)
;;; OUTPUT: Vectores cuya semejanza con respecto a la
;;;         categoria es superior al nivel de confianza ,
;;;         ordenados
;;;


(defun order-vectors-cosine-distance (vector lst-of-vectors &optional (confidence-level 0))
  (if (>= (- 1 confidence-level)
         (cosine-distance-mapcar vector (first lst-of-vectors)))
    (if (null (rest lst-of-vectors))
      (order-lst-vectors vector (list (cosine-distance-mapcar vector (first lst-of-vectors)) (first lst-of-vectors)) '())
      (order-lst-vectors vector (list (cosine-distance-mapcar vector (first lst-of-vectors)) (first lst-of-vectors))
      (order-vectors-cosine-distance vector (rest lst-of-vectors) confidence-level)))
    (if (null (rest lst-of-vectors))
      nil
      (order-vectors-cosine-distance vector (rest lst-of-vectors) confidence-level))))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; get-vectors-category (categories vectors distance-measure)
;;; Clasifica a los textos en categorias .
;;;
;;; INPUT : categories: vector de vectores, representado como
;;;                     una lista de listas
;;;         texts:      vector de vectores, representado como
;;;                     una lista de listas
;;;         distance-measure: funcion de distancia
;;; OUTPUT: Pares formados por el vector que identifica la categoria
;;;         de menor distancia , junto con el valor de dicha distancia
;;;
( defun get-vectors-category (categories texts distance-measure)
  (if (or (null categories) (null texts))
      NIL
  (mapcar #'(lambda(x) (get-text-category categories x distance-measure (list (first (first categories))
            (funcall distance-measure (rest (first categories)) (rest x))))) texts)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; get-text-category (categories text distance-measure min-category)
;;; A partir de un texto devolvemos el identificador de la categoria que lo aproxima y su distancia.
;;;
;;; INPUT : categories: vector de vectores, representado como
;;;                     una lista de listas
;;;         text:      vector, representado como una lista
;;;         distance-measure: funcion de distancia
;;;         min-category: la categoria minima para comenzar la iteracion (la primera categoria por defecto)
;;; OUTPUT: Par formado por el vector que identifica la categoria
;;;         de menor distancia , junto con el valor de dicha distancia


(defun get-text-category (categories text distance-measure min-category)
  (if (null categories)
      min-category
    (if (< (funcall distance-measure (rest (first categories)) (rest text))
           (second min-category))
      (get-text-category (rest categories) text distance-measure (list (first (first categories))
                                                                  (funcall distance-measure (rest (first categories)) (rest text))))
      (get-text-category (rest categories) text distance-measure min-category))))



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; EJERCICIO 2
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; newton
;;; Estima el cero de una funcion mediante Newton-Raphson
;;;
;;; INPUT : f: funcion cuyo cero se desea encontrar
;;;         df: derivada de f
;;;         max-iter: maximo numero de iteraciones
;;;         x0: estimacion inicial del cero (semilla)
;;;         tol: tolerancia para convergencia (parametro opcional)
;;; OUTPUT: estimacion del cero de f o NIL si no converge
;;;
(defun newton (f df max-iter x0 &optional (tol 0.001))
  (if (= max-iter -1) NIL
  (if (< (abs (funcall f x0)) tol) x0
      (newton f df (- max-iter 1) (- x0 (/ (funcall f x0) (funcall df x0))) tol))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; one-root-newton
;;; Prueba con distintas semillas iniciales hasta que Newton
;;; converge
;;;
;;; INPUT: f : funcion de la que se desea encontrar un cero
;;;        df : derivada de f
;;;        max-iter : maximo numero de iteraciones
;;;        semillas : semillas con las que invocar a Newton
;;;        tol : tolerancia para convergencia ( parametro opcional )
;;;
;;; OUTPUT: el primer cero de f que se encuentre , o NIL si se diverge
;;;          para todas las semillas
;;;
(defun one-root-newton (f df max-iter semillas &optional (tol 0.001))
  (cond ((null semillas) nil)
          ((newton f df max-iter (first semillas) tol)
           (newton f df max-iter (first semillas) tol))
          (t (one-root-newton f df max-iter (rest semillas) tol))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; all-roots-newton
;;; Prueba con distintas semillas iniciales y devuelve las raices
;;; encontradas por Newton para dichas semillas
;;;
;;; INPUT: f: funcion de la que se desea encontrar un cero
;;;        df: derivada de f
;;;        max-iter: maximo numero de iteraciones
;;;        semillas: semillas con las que invocar a Newton
;;;        tol : tolerancia para convergencia ( parametro opcional )
;;;
;;; OUTPUT: las raices que se encuentren para cada semilla o nil
;;;          si para esa semilla el metodo no converge
;;;
(defun all-roots-newton (f df max-iter semillas &optional ( tol 0.001))
  (mapcar #'(lambda(x) (newton f df max-iter x tol)) semillas))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; list-not-nil-newton
;;; Prueba con distintas semillas iniciales y devuelve las raices
;;; encontradas por Newton para dichas semillas (sin nil)
;;;
;;; INPUT: f: funcion de la que se desea encontrar un cero
;;;        df: derivada de f
;;;        max-iter: maximo numero de iteraciones
;;;        semillas: semillas con las que invocar a Newton
;;;        tol : tolerancia para convergencia ( parametro opcional )
;;;
;;; OUTPUT: las raices que se encuentren para cada semilla
;;;

(defun list-not-nil-roots-newton (f df max-iter semillas &optional ( tol 0.001))
    (mapcan #'(lambda(x) (unless (null x) (list x))) (all-roots-newton f df max-iter semillas tol)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; EJERCICIO 3
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; combine-elt-lst
;;; Combina un elemento dado con todos los elementos de una lista
;;;
;;; INPUT: elem: elemento a combinar
;;;        lst: lista con la que se quiere combinar el elemento
;;;
;;; OUTPUT: lista con las combinacion del elemento con cada uno de los
;;;         de la lista
(defun combine-elt-lst (elt lst)
  (cond ((or (null elt) (null lst))
              nil)
        (t (mapcar #'(lambda(x) (list elt x)) lst))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; combine-lst-lst
;;; Calcula el producto cartesiano de dos listas
;;;
;;; INPUT: lst1: primera lista
;;;        lst2: segunda lista
;;;
;;; OUTPUT: producto cartesiano de las dos listas
(defun combine-lst-lst (lst1 lst2)
  (cond ((or (null lst1) (null lst2))
         nil)
        (t (mapcan #'(lambda(x) (combine-elt-lst x lst2)) lst1))))

;;FUNCIONES AUXILIARES PARA EL 3.3;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; combine-cons-elt-lst
;;; Combina un elemento dado con todos los elementos de una lista (utilizando cons)
;;;
;;; INPUT: elem: elemento a combinar
;;;        lst: lista con la que se quiere combinar el elemento
;;;
;;; OUTPUT: lista con las combinacion del elemento con cada uno de los
;;;         de la lista

(defun combine-cons-elt-lst (elt lst)
  (cond ((or (null elt) (null lst))
              nil)
        (t (mapcar #'(lambda(x) (cons elt x)) lst))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; combine-append-lst-lst
;;; Calcula el producto cartesiano de dos listas (utilizando append)
;;;
;;; INPUT: lst1: primera lista
;;;        lst2: segunda lista
;;;
;;; OUTPUT: producto cartesiano de las dos listas

(defun combine-append-lst-lst (lst1 lst2)
  (cond ((or (null lst1) (null lst2))
         nil)
        (t (append (combine-cons-elt-lst (first lst1) lst2) (combine-append-lst-lst (rest lst1) lst2)))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; combine-list-of-lsts
;;; Calcula todas las posibles disposiciones de elementos
;;; pertenecientes a N listas de forma que en cada disposicion
;;; aparezca unicamente un elemento de cada lista
;;;
;;; INPUT: lstolsts: lista de listas
;;;
;;; OUTPUT: lista con todas las posibles combinaciones de elementos

(defun combine-list-of-lsts (lstolsts)
  (cond ((null lstolsts)
         (list nil))
        (t (combine-append-lst-lst (first lstolsts)
                            (combine-list-of-lsts (rest lstolsts))))))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; EJERCICIO 4
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; defino operadores logicos
(defconstant +bicond+ '<=>)
(defconstant +cond+   '=>)
(defconstant +and+    '^)
(defconstant +or+     'v)
(defconstant +not+    '!)

;; definiciones de valores de verdad, conectores y atomos
(defun truth-value-p (x)
  (or (eql x T) (eql x NIL)))

(defun unary-connector-p (x)
  (eql x +not+))

(defun binary-connector-p (x)
  (or (eql x +bicond+)
      (eql x +cond+)))

(defun n-ary-connector-p (x)
  (or (eql x +and+)
      (eql x +or+)))

(defun bicond-connector-p (x)
  (eql x +bicond+))

(defun cond-connector-p (x)
    (eql x +cond+))

(defun connector-p (x)
  (or (unary-connector-p  x)
      (binary-connector-p x)
      (n-ary-connector-p  x)))

(defun positive-literal-p (x)
  (and (atom x)
       (not (truth-value-p x))
       (not (connector-p x))))

(defun negative-literal-p (x)
  (and (listp x)
       (eql +not+ (first x))
       (null (rest (rest x)))
       (positive-literal-p (second x))))

(defun literal-p (x)
  (or (positive-literal-p x)
      (negative-literal-p x)))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; truth-tree
;;; Recibe una expresion y construye su arbol de verdad para
;;; determinar si es SAT o UNSAT
;;;
;;; INPUT  : fbfs - Formula bien formada (FBF) a analizar.
;;; OUTPUT : T   - FBFs es SAT
;;;          N   - FBFs es UNSAT
;;;

(defun truth-tree (fbfs)
  (if (null (first fbfs)) nil
  (truth-tree-check (truth-tree-aux nil (expand fbfs))))

  )

(defun insert-elt (elt lst)
  (cond ((null lst) nil)
        ((literal-p (first lst))
         (cons (list elt (first lst)) (insert-elt elt (rest lst))))
        (t (cons (cons elt (first lst)) (insert-elt elt (rest lst))))
    )
  )


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; truth-tree-aux
;;; Funcion auxiliar que recibe una expresion y construye su arbol de verdad para
;;; determinar si es SAT o UNSAT
;;;
;;; INPUT  : fbfs - Formulas bien formada (FBF) que forman una base
;;;          lst - lista de atomos
;;; OUTPUT : literals - Listas de atomos que habrá que analizar después
;;;

(defun truth-tree-aux (lst fbfs)

  (cond ((eql +and+ fbfs) lst)
        ((literal-p fbfs)
         (if (null lst)
           (truth-tree-aux (list fbfs) +and+)
           (truth-tree-aux (insert-elt fbfs lst) +and+)))
        ((eql +and+ (first fbfs))
         (if (null (second fbfs))
             lst
             (truth-tree-aux (truth-tree-aux lst (second fbfs)) (expand (cddr fbfs))))
           )
        ((eql +or+ (first fbfs))
         (mapcar #'(lambda(x) (truth-tree-aux lst x)) (rest fbfs)))
        (t nil)
    )

  )

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; check-lst-lst
;;; Recibe una lista y comprueba si es una lista de listas
;;;
;;; INPUT  : list - lista a analizar
;;; OUTPUT : T   - no es una lista de listas
;;;          N   - es una lista de listas
;;;

(defun check-lst-lst (lst)
  (if (null lst)
    t
    (if (literal-p (first lst))
      (check-lst-lst (rest lst))
      nil)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; truth-tree-check
;;; Recibe una expresion y comprueba si hay contradicciones
;;;
;;; INPUT  : lst - Expresion a analizar.
;;; OUTPUT : T   - No hay contracciones
;;;          N   - Hay contradicciones
;;;

(defun truth-tree-check (lst)
  (cond ((null lst) nil)
        ((literal-p lst) t)
        ((check-lst-lst lst)
         (contradiction lst))
        ((null (truth-tree-check (first lst)))
         (truth-tree-check (rest lst)))
        (t t)
    )
  )

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; contradiction
;;; Recibe una expresion y devuelve si es contradictoria o no
;;;
;;; INPUT  : lst - lst a analizar.
;;; OUTPUT : T   - No es contradictoria
;;;          N   - Es contradictoria
;;;

(defun contradiction (lst)
  (cond ((null lst) t)
        ((contradiction-aux (first lst) lst)
          (contradiction (rest lst)))
        (t nil)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; contradiction-aux
;;; Funcion auxiliar de contradiction
;;;
;;; INPUT  : lst - lst a analizar.
;;;          frst - elemento a comparar
;;; OUTPUT : T   - No es contradictoria
;;;          N   - Es contradictoria
;;;

(defun contradiction-aux (frst lst)
  (cond ((null lst) t)
        ((negative-literal-p frst)
            (if (eql (second frst) (second lst))
              nil
              (contradiction-aux frst (rest lst))))
        ((and (positive-literal-p frst) (negative-literal-p (second lst)))
            (if (eql frst (second (second lst)))
              nil
              (contradiction-aux frst (rest lst))))
        (t (contradiction-aux frst (rest lst)))
    )
  )


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; convert
;;; Recibe una expresion y la convierte en una expresion con and's y or's
;;;
;;; INPUT  : fbf - Formula bien formada (FBF) a analizar.
;;; OUTPUT : fbf-modified FBF modificada
;;;

(defun convert (fbf)
  (cond ((or (literal-p fbf) (connector-p fbf)) fbf)
        ((bicond-connector-p (first fbf)) (convert (bicond fbf)))
        ((cond-connector-p (first fbf)) (convert (conditional fbf)))
        ((unary-connector-p (first fbf))
              (cond ((bicond-connector-p (first (first (rest fbf))))
                     (convert (neg-bicond (second fbf))))
                    ((cond-connector-p (first (first (rest fbf))))
                     (convert (neg-conditional (second fbf))))
                    ((eql +or+ (first (first (rest fbf))))
                     (convert (de-morgan-or (second fbf))))
                    ((eql +and+ (first (first (rest fbf))))
                     (convert (de-morgan-and (second fbf))))
                    ((unary-connector-p (first (first (rest fbf))))
                     (convert (double-negation (second fbf))))
                    (t fbf)))
        ((n-ary-connector-p (first fbf))
         (mapcar #'(lambda(x) (convert x)) fbf))
        (t fbf)
    )
  )

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; expand
;;; Recibe la base de conocimiento y la convierte en una expresion con and's y or's
;;;
;;; INPUT  : fbfs - Formula bien formada (FBF) a analizar.
;;; OUTPUT : fbfs-modified FBF modificada
;;;

(defun expand (fbfs)
    (cons +and+ (mapcar #'(lambda(x) (convert x)) fbfs)))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; de-morgan-or
;;; Recibe una expresion y aplica la regla de derivacion adecuada
;;;
;;; INPUT  : fbf - Formula bien formada (FBF) a analizar.
;;; OUTPUT : fbf-modified FBF modificada
;;;

(defun de-morgan-or (fbf)
  (cond ((null (rest fbf)) (list (list +not+ (first fbf))))
        ((n-ary-connector-p (first fbf)) (cons +and+ (de-morgan-or (rest fbf))))
        (t (append (list (list +not+ (first fbf))) (de-morgan-or (rest fbf))))))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; de-morgan-and
;;; Recibe una expresion y aplica la regla de derivacion adecuada
;;;
;;; INPUT  : fbf - Formula bien formada (FBF) a analizar.
;;; OUTPUT : fbf-modified FBF modificada
;;;

(defun de-morgan-and (fbf)
(cond ((null (rest fbf)) (list (list +not+ (first fbf))))
      ((n-ary-connector-p (first fbf)) (cons +or+ (de-morgan-and (rest fbf))))
      (t (append (list (list +not+ (first fbf))) (de-morgan-and (rest fbf))))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; neg-conditional
;;; Recibe una expresion y aplica la regla de derivacion adecuada
;;;
;;; INPUT  : fbf - Formula bien formada (FBF) a analizar.
;;; OUTPUT : fbf-modified FBF modificada
;;;

(defun neg-conditional(fbf)
  (list +and+ (second fbf) (list +not+ (third fbf))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; neg-bicond
;;; Recibe una expresion con una doble condicion y aplica la regla de derivacion adecuada
;;;
;;; INPUT  : fbf - Formula bien formada (FBF) a analizar.
;;; OUTPUT : fbf-modified FBF sin doble condicional
;;;

(defun neg-bicond(fbf)
  (list +or+ (list +and+ (second fbf) (list +not+ (third fbf)))
        (list +and+ (list +not+ (second fbf)) (third fbf))))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; conditional
;;; Recibe una expresion con una condicion y aplica la regla de derivacion adecuada
;;;
;;; INPUT  : fbf - Formula bien formada (FBF) a analizar.
;;; OUTPUT : fbf-modified FBF sin condicional
;;;

(defun conditional(fbf)
  (list +or+ (list +not+ (second fbf)) (third fbf)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; bicond
;;; Recibe una expresion con una doble condicion y aplica la regla de derivacion adecuada
;;;
;;; INPUT  : fbf - Formula bien formada (FBF) a analizar.
;;; OUTPUT : fbf-modified FBF sin doble condicional
;;;

(defun bicond(fbf)
  (list +or+ (list +and+ (second fbf) (third fbf))
        (list +and+ (list +not+ (second fbf)) (list +not+ (third fbf)))))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; double-negation
;;; Recibe una expresion con una doble negacion y aplica la regla de derivacion adecuada
;;;
;;; INPUT  : fbf - Formula bien formada (FBF) a analizar.
;;; OUTPUT : fbf-modified FBF sin doble condicional
;;;

(defun double-negation(fbf)
  (second fbf))



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; EJERCICIO 5
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; shortest-path-improved
;;; Version de busqueda en anchura que no entra en recursion
;;; infinita cuando el grafo tiene ciclos y que encuentra el camino mas corto
;;; INPUT:   end: nodo final
;;;          start: nodo inicial
;;;          net: grafo
;;; OUTPUT: camino mas corto entre dos nodos
;;;         nil si no lo encuentra

; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; ;; B r e a d t h - f i r s t - s e a r c h in graphs
; ;;


(defun bfs-improved (end queue net)
  (bfs-improved-aux end queue net NIL))


( defun bfs-improved-aux ( end queue net rpt-lst)
  ( if ( null queue ) '()
    ( let* (( path ( first queue ))
      ( node ( first path )))
      ( if ( eql node end )
        ( reverse path )
        (if (null (find node rpt-lst))
            (bfs-improved-aux end (append (rest queue) (new-paths path node net)) net (cons node rpt-lst))
          (bfs-improved-aux end (rest queue) net rpt-lst))))))

( defun new-paths ( path node net )
  ( mapcar #'( lambda ( n ) (cons n path )) ( rest ( assoc node net ))))


( defun shortest-path-improved-aux ( start end net)
  ( bfs-improved end ( list ( list start )) net))

(defun shortest-path-improved (start end net)
  (shortest-path-improved-aux start end net)
  )
; ;;


; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
