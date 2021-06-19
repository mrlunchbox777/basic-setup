#run-send-message.sh
run-send-message () {
  echo "********************************************************"
  echo "*"
  echo "* $(date)"
  for f in "$@"; do echo "* $f"; done
  echo "*"
  echo "********************************************************"
}