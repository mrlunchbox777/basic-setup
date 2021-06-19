# run identify shell function
run-full-update-basic-setup () {
  local shell=$(ps -o args= -p "$$" | awk '{print $1}' | awk -F '/' '{print $NF}')
  ehco "$shell"
}