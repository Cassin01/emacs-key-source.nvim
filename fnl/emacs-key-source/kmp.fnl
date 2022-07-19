(fn _dump [o depth]
  "dump the object"
  (if (= (type o) :table)
    (let [s ["{\n"]]
      (each [k v (pairs o)]
        (table.insert s (.. depth "  [" (tostring k) "] = " (_dump v (.. depth "  ")) ",\n")))
      (table.insert s (.. depth "} "))
      (table.concat s ""))
    (tostring o)))
(fn dump [o]
  (print (_dump o "")))

(fn _escaper [str]
  (if (= str :\) :\\ str))
(fn _vim_eq [pat txt ignorecase]
  "a, b must be a char"
  (= 1 (vim.api.nvim_eval (.. "\""
                              (_escaper pat)
                              (if ignorecase "\" == \"" "\" ==# \"")
                              (_escaper txt)
                              "\""))))

(fn kmp-list [pat m]
  "m: pat length"
  (var lps [1])
  (var i 2)
  (var len 1)
  (while (<= i m)
    (if (= (. pat i) (. pat len))
      (do
        (set len (+ len 1))
        (tset lps i len)
        (set i (+ i 1)))
      (if (not= len 1)
        (set len (. lps (- len  1)))
        (do
          (tset lps i 1)
          (set i (+ i 1))))))
  lps)

(fn kmp-search [pat txt m n lps ignorecase]
  (var j 1)
  (var i 1)
  (var res [])
  (while (<= i n)
    ; (when (= (. txt i) (. pat j))
    (when (_vim_eq (. pat j) (. txt i) ignorecase)
      (set i (+ i 1))
      (set j (+ j 1)))
    (if
      (= j (+ m 1))
      (do ; found pattern at index (- i m)
        (table.insert res (- i m))
        (set j (. lps (- j 1))))
      ; (and (<= i n) (not= (. pat j) (. txt i)))
      (and (<= i n) (not (_vim_eq (. pat j) (. txt i) ignorecase)))
      (if (not= j 1)
        (set j (. lps (- j 1)))
        (set i (+ i 1)))
      nil))
  res)

(fn str2list [str]
  (var list [])
  (var len 0)
  (for [i 1 (string.len str)]
    (set len (+ len 1))
    (tset list i (string.sub str i i)))
  (values list len))

(fn kmp [pattern text ignorecase]
  (let [(pat m) (str2list pattern)
        (txt n) (str2list text)]
    (kmp-search pat txt m n (kmp-list pat m) ignorecase)))


; (dump (str2list "abcd"))
; (local target (str2list "aaabaaa"))
; (local txt (str2list "aabaacaadaabaaba"))
; (local pat (str2list "aaba"))
; (dump (kmp "aaba" "aabaacaadaabaaba"))
; (dump (kmp pat txt))
; (print (_vim_eq "a" "A"))

{: kmp}
