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

(defn ok [ct body]
 {:status 200 :headers {"Content-Type" ct} :body body})

(defn handler
 [{:uri uri :query-string qs}]
 (cond
  (string/has-prefix? "/api/" uri)
  (let [response (curl-esv (string (string/slice uri 5) "?" qs))]
    (if (string/find "<!DOCTYPE html>" response)
      {:status 404 :body "Not Found"}
      (ok ct/json response)))
  (= uri "/search.svg") (ok ct/svg (slurp "search.svg"))
  true (ok ct/html (slurp "index.html"))))

(defn main [& args]
  (let [port (eval-string (os/getenv "PORT"))]
    (circlet/server handler port "0.0.0.0")))
