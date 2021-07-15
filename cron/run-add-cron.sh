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

orig_dir="$(pwd)"
source="${BASH_SOURCE[0]}"
run-get-source-and-dir "$source"
source="${rgsd[@]:0:1}"
dir="${rgsd[@]:1:1}"
cd "$dir"

if [ -f "../.env" ]; then
  source ../.env
fi

# Should Install
should_install_run_update_basic_setup=${BASICSETUPCRONSHOULDINSTALLRUNUPDATEBASICSETUP:-true}
should_install_run_update_cron_basic_setup=${BASICSETUPCRONSHOULDINSTALLRUNUPDATECRONBASICSETUP:-true}
should_install_run_write_temp_file=${BASICSETUPCRONSHOULDINSTALLRUNWRITETEMPFILE:-false}

# Minute
run_update_basic_setup_min=${BASICSETUPCRONRUNUPDATEBASICSETUPMIN:-0}
run_update_cron_basic_setup_min=${BASICSETUPCRONRUNUPDATECRONBASICSETUPMIN:-5}

# Hour
run_update_basic_setup_hour=${BASICSETUPCRONRUNUPDATEBASICSETUPHOUR:-0}
run_update_cron_basic_setup_hour=${BASICSETUPCRONRUNUPDATECRONBASICSETUPHOUR:-0}

# Day of Month (dom)
# run_update_basic_setup_dom=${BASICSETUPCRONRUNUPDATEBASICSETUPDOM:-"0"}

# Month
# run_update_basic_setup_mon=${BASICSETUPCRONRUNUPDATEBASICSETUPMON:-"0"}

# Day of Week (dow)
# run_update_basic_setup_dow=${BASICSETUPCRONRUNUPDATEBASICSETUPDOW:-"0"}

run-add-cron-basic-setup() {
  if [ -z "$1" ]; then
    run-send-message "Empty cron... skipping"
    return 0;
  fi

  local found_cron_entry="false"
  local file_name="$1"
  local var_name="$(echo $1 | sed -r 's/-/_/g')"

  local check_for_run_variable_name="should_install_$(echo $var_name)"
  if [ "${!check_for_run_variable_name}" == true ]; then
    local cron_min_name="$(echo $var_name)_min"
    local cron_hour_name="$(echo $var_name)_hour"
    local cron_dom_name="$(echo $var_name)_dom"
    local cron_month_name="$(echo $var_name)_month"
    local cron_dow_name="$(echo $var_name)_dow"

    local cron_min="${!cron_min_name}"
    local cron_hour="${!cron_hour_name}"
    local cron_dom="${!cron_dom_name}"
    local cron_month="${!cron_month_name}"
    local cron_dow="${!cron_dow_name}"

    local cron_min="$(echo $cron_min | sed 's/^$/*/')"
    local cron_hour="$(echo $cron_hour | sed 's/^$/*/')"
    local cron_dom="$(echo $cron_dom | sed 's/^$/*/')"
    local cron_month="$(echo $cron_month | sed 's/^$/*/')"
    local cron_dow=$(echo $cron_dow | sed 's/^$/*/')""

    local cron_script_string="$cron_min $cron_hour $cron_dom $cron_month $cron_dow '$dir/jobs/$file_name.sh'"
    echo "basic-setup-run-add-cron for '$cron_script_string'"
    crontab -l 2>/dev/null | grep -F -q "$cron_script_string" && found_cron_entry="true"
    if [ "${found_cron_entry}" != "true" ]; then
      (crontab -l 2>/dev/null; echo "$cron_script_string") | crontab -
    else
      echo "already found and skipping - $cron_script_string"
    fi
  else
    echo "skipping, env set to false - "${check_for_run_variable_name}" == ${!check_for_run_variable_name}"
  fi
}

run-add-cron-basic-setup "run-update-basic-setup"
run-add-cron-basic-setup "run-update-cron-basic-setup"
run-add-cron-basic-setup "run-write-temp-file"

cd "$orig_dir"
