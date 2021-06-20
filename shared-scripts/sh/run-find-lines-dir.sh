# run find lines dir function
run-find-lines-dir-basic-setup () {
  find -type f | xargs cat | wc -l
}
