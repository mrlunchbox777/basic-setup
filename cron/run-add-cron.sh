#!/bin/bash
#run-add-cron.sh

[ ! -d "$shared_scripts_path" ] && shared_scripts_path="./shared-scripts"
[ ! -d "$shared_scripts_path" ] && shared_scripts_path=$(find /home/ -type d -wholename "*basic-setup/shared-scripts")
[ ! -d "$shared_scripts_path" ] && shared_scripts_path=$(find $HOME/src/tools -type d -wholename "*basic-setup/shared-scripts")
[ ! -d "$shared_scripts_path" ] && shared_scripts_path=$(find ./ -type d -wholename "*basic-setup/shared-scripts")
[ ! -d "$shared_scripts_path" ] && shared_scripts_path=$(find $HOME/src -type d -wholename "*basic-setup/shared-scripts")
[ ! -d "$shared_scripts_path" ] && shared_scripts_path=$(find $HOME/ -type d -wholename "*basic-setup/shared-scripts")
[ ! -d "$shared_scripts_path" ] && shared_scripts_path=$(find / -type d -wholename "*basic-setup/shared-scripts")
if [ ! -d "$shared_scripts_path" ]; then
    echo -e "error finding shared-scripts..." >&2
    exit 1
fi
for basic_setup_generalrc_sh_f in $(ls "$shared_scripts_path/sh/"); do . "$shared_scripts_path/sh/$basic_setup_generalrc_sh_f"; done

source="${BASH_SOURCE[0]}"
run-get-source-and-dir "$source"
source="${rgsd[@]:0:1}"
dir="${rgsd[@]:1:1}"

run-add-cron-basic-setup() {
  if [ -z "$1" ]; then
    run-send-message "Empty cron... skipping"
    return 0;
  fi

  local found_cron_entry="false"
  crontab -l 2>/dev/null | grep -q "$1" && found_cron_entry="true"
  echo "found_cron_entry=$found_cron_entry"
  if [ "${found_cron_entry}" != "true" ]; then
    (crontab -l 2>/dev/null; echo "$1") | crontab -
  fi
}

run-add-cron-basic-setup ""
run-add-cron-basic-setup "*/5 * * * * \"$dir/jobs/run-write-temp-file.sh\""
run-add-cron-basic-setup ""
# */5 * * * * /path/to/job -with args
