(import circlet)

(defn curl-esv [path]
  (let [auth (string "'Authorization: Token " (os/getenv "ESV_API_TOKEN") "'")
        url (string "'https://api.esv.org/v3/" path "'")
        cmd (string/join ["curl" url "-H" auth "--silent"] " ")]
    (with [f (file/popen cmd)]
      (file/read f :all))))

(def ct/json "application/json")
(def ct/html "text/html")
(def ct/svg "image/svg+xml")

(def res-cache @{})

(defn ok [ct body]
 {:status 200 :headers {"Content-Type" ct} :body body})

(defn handler
 [{:uri uri :query-string qs}]
 (cond
  (string/has-prefix? "/api/" uri)
  (let [full-uri (string (string/slice uri 5) "?" qs)
        response (or (res-cache full-uri) (curl-esv full-uri))]
    (if (or (string/find "<!DOCTYPE html>" response)
            (string/find "Request was throttled" response))
      {:status 404 :body `{"error": "Not Found"}`}
      (do
       (put res-cache full-uri response)
       (ok ct/json response))))
  (= uri "/search.svg") (ok ct/svg (slurp "search.svg"))
  true (ok ct/html (slurp "index.html"))))

(defn main [& args]
  (let [port (eval-string (os/getenv "PORT"))]
    (circlet/server handler port "0.0.0.0")))
