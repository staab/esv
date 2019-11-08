(declare-project
  :name "esv"
  :description "A simple reader for the ESV version of the Bible"
  :dependencies ["https://github.com/janet-lang/circlet.git"
                 "https://github.com/staab/janet-cache.git"])

(declare-executable
 :name "main"
 :entry "esv/main.janet")
