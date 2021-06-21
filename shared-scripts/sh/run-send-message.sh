#run-send-message.sh
run-send-message () {
  echo "********************************************************"
  echo "*"
  echo "* $(date)"
  for run_send_message_f in "$@"; do echo "* $run_send_message_f"; done
  echo "*"
  echo "********************************************************"
}