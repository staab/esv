(def ffirst (comp first first))

(defn sort-by-t [xs]
  (sorted xs (fn [[_ a] [_ b]] (< (a :t) (b :t)))))

(defn cache-get [c k]
  (when-let [entry ((c :entries) k)]
    (put entry :t (os/time))
    (entry :v)))

(defn cache-put [c k v]
  (let [{:entries xs :size size :max-size max-size} c]
    (when (nil? (xs k))
      (put xs k @{:v v :t (os/time)})
      (if (>= size max-size)
        (put xs (ffirst (sort-by-t (pairs xs))) nil)
        (put c :size (inc size))))))

(defn create [&opt opts]
  @{:size 0
    :max-size (get opts :max-size 1)
    :entries @{}
    :get cache-get
    :put cache-put})
