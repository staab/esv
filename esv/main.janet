(import circlet)
(import staab.cache/lru :as lru)

(defn curl-esv [path]
  (let [auth (string "'Authorization: Token " (os/getenv "ESV_API_TOKEN") "'")
        url (string "'https://api.esv.org/v3/" path "'")
        cmd (string/join ["curl" url "-H" auth "--silent"] " ")]
    (with [f (file/popen cmd)]
      (file/read f :all))))

(def ct/json "application/json")
(def ct/html "text/html")
(def ct/svg "image/svg+xml")

(def res-cache (lru/create {:max-size 50}))

(defn ok [ct body]
 {:status 200 :headers {"Content-Type" ct} :body body})

(defn bad [status-code body]
 {:status status-code :headers {"Content-Type" ct/json} :body body})

(defn handler
 [{:uri uri :query-string qs}]
 (cond
  (string/has-prefix? "/api/" uri)
  (let [full-uri (string (string/slice uri 5) "?" qs)
        cached-res (:get res-cache full-uri)
        response (or cached-res (curl-esv full-uri))
        not-found? (string/find "<!DOCTYPE html>" response)
        throttled? (string/find "Request was throttled" response)]
    (cond
     not-found? (bad 404 `{"detail": "We couldn't find anything for your query."}`)
     throttled? (bad 429 response)
     true (do (:put res-cache full-uri response) (ok ct/json response))))
  (= uri "/search.svg") (ok ct/svg (slurp "search.svg"))
  true (ok ct/html (slurp "index.html"))))

(defn log-handler [h]
  (fn [req]
    (let [res (h req)]
      (pp (string (req :uri) "?" (req :query-string) " => " (res :status)))
      res)))

(defn main [& args]
  (let [port (eval-string (os/getenv "PORT"))]
    (circlet/server (log-handler handler) port "0.0.0.0")))
