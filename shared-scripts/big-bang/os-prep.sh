#! /usr/bin/env bash

# Steps adapted from https://github.com/DoD-Platform-One/big-bang/blob/master/docs/guides/deployment-scenarios/quickstart.md#step-4-configure-host-operating-system-prerequisites

set -e
trap 'echo ❌ exit at ${0}:${LINENO}, command was: ${BASH_COMMAND} 1>&2' ERR
# TODO: tool validation

#
# global defaults
#
BACKUP_ONLY=false
BASE_OUT_DIR="$HOME/.basic-setup/big-bang/os-prep/"
DRY_RUN=false
OPEN_FILE=""
PERSIST=false
RESTORE_ARCHIVE_FILE=""
SHOULD_CLEAN=false
SHOULD_LIST=false
SHOW_HELP=false
TARGET_VM_MAX_MAP_COUNT=524288
TARGET_FS_FILE_MAX=131072
TARGET_OPEN_FILE_COUNT_LIMIT=131072
TARGET_PROCESS_LIMIT=8192
VERBOSITY=0

#
# computed values (often can't be alphabetical)
#
RUN_TIMESTAMP="$(date +%s)"
OPEN_COMMAND="t=\"/tmp/$RUN_TIMESTAMP/\"; mkdir -p \$t; tar xf \"\$OPEN_FILE\" --directory=\$t; code \$t"
OUT_DIR="${BASE_OUT_DIR}backup-ran-${RUN_TIMESTAMP}/"
ARCHIVE_FILE="$(echo "$OUT_DIR" | sed 's/.$//').tgz"
MANIFEST_OUT_FILE="${OUT_DIR}manifest.json"
TEMP_CONFIG_OUT_FILE="${OUT_DIR}sysctl-temp-config-backup.conf"
CONFIG_FILES_OUT_DIR="${OUT_DIR}sysctl-d-backup/"
ULIMIT_CONFIG_OUT_FILE="${OUT_DIR}ulimit-config-backup.json"
RESTORE_DIR="${BASE_OUT_DIR}restore-ran-${RUN_TIMESTAMP}/"
MANIFEST_RESTORE_FILE="${RESTORE_DIR}manifest.json"
TEMP_CONFIG_RESTORE_FILE="${RESTORE_DIR}sysctl-config-backup.conf"
FILES_RESTORE_DIR="${RESTORE_DIR}sysctl-d-backup/"
ULIMIT_CONFIG_RESTORE_FILE="${RESTORE_DIR}ulimit-config-backup.json"

#
# helper functions
#

# script help message
function help {
	command_for_help="$(basename "$0")"
	cat <<- EOF
		----------
		usage: $command_for_help <arguments>
		----------
		-b|--backup-only - (flag, default: false) Exit after backup.
		-c|--clean       - (flag, default: false) Delete everything in $BASE_OUT_DIR and exit.
		-d|--dry-run     - (flag, default: false) Writes out deletes and updates, still creates (not restores) backups.
		-h|--help        - (flag, default: false) Print this help message and exit.
		-l|--list        - (flag, default: false) Print the possible restore points and exit.
		-o|--open        - (optional, default: 'latest') Archive to run the --open-command against and exit. Pass 'latest' to restore from latest archive file.
		-p|--persist     - (flag, default: false) Persist the changes through a restart (write files).
		-r|--restore     - (optional, default: 'latest') Archive to restore settings from and exit. Pass 'latest' to restore from latest archive file.
		-v|--verbose     - (multi-flag, default: 0) Increase the verbosity by 1.
		--open-command   - (optional, default: '$OPEN_COMMAND') The command to run with -o. \$OPEN_FILE will be replaced by -o.
		--out            - (optional, default: '$ARCHIVE_FILE') Absolute path of out archive.
		----------
		note: The Unix timestamp when this command was run was used several times above, it is '$RUN_TIMESTAMP'.
		----------
		examples:
		setup                 - $command_for_help -p -v
		test setup            - $command_for_help -d -p
		temp setup            - $command_for_help -v
		list backups          - $command_for_help -l
		clean backups         - $command_for_help -c -v
		restore latest backup - $command_for_help -r -v
		open latest backup    - $command_for_help -o
		get current settings  - $command_for_help -b --out current_settings.tgz
		----------
	EOF
}

# ensure that an outfile dir exists
function ensure_out_file_dir {
	out_file="$1"
	(($VERBOSITY > 1)) && echo "out_file - $out_file"
	out_file_dir="$(dirname "$out_file")"
	(($VERBOSITY > 1)) && echo "out_file_dir - $out_file_dir"
	if [ ! -d "$out_file_dir" ]; then
		(($VERBOSITY > 0)) && echo "creating $out_file_dir..."
		mkdir -p $out_file_dir
	fi
}

# delete the backups
function clean_backups {
	# TODO: confirm?
	if [ ! -d "$BASE_OUT_DIR" ]; then
		(($VERBOSITY > 0)) && echo "no backup folder found, exiting..."
		exit 0
	fi
	local extra_args=""
	if (($VERBOSITY > 0)); then
		local extra_args="-v"
	fi
	if (( $(ls $BASE_OUT_DIR | wc -l) > 0 )); then
		(($VERBOSITY > 0)) && echo "found files, cleaning..."
		if [ "$DRY_RUN" == true ]; then
			echo "would remove the following:"
			echo "$BASE_OUT_DIR"
			general-ls-recursive "$BASE_OUT_DIR"
		else
			sudo rm $extra_args -rf $BASE_OUT_DIR
		fi
		exit 0
	else
		(($VERBOSITY > 0)) && echo "found no files, exiting..."
		exit 0
	fi
}

# add an item to the manifest
function update_manifest {
	local new_items="$1"
	local manifest_content="$(jq . "$MANIFEST_OUT_FILE" | jq '.items += '"$new_items"' ')"
	echo "$manifest_content" > "$MANIFEST_OUT_FILE"
}

# create backup manifest
function backup_manifest {
	ensure_out_file_dir "$MANIFEST_OUT_FILE"
	local manifest_content=$(
		cat <<- EOF
			{
				"items": [
					{"type": "manifest", "value": "$(basename "$MANIFEST_OUT_FILE")"}
				],
				"timestamp": "$RUN_TIMESTAMP"
			}
		EOF
	)
	echo "$manifest_content" | jq . > "$MANIFEST_OUT_FILE"
}

# backup current sysctl config
function backup_sysctl_config {
	# get the temp config data
	ensure_out_file_dir "$TEMP_CONFIG_OUT_FILE"
	sudo sysctl -a > $TEMP_CONFIG_OUT_FILE
	# prep the manifest entries
	local temp_config_entry='[{"type": "temp_config", "value": "'"$(basename "$TEMP_CONFIG_OUT_FILE")"'"}]'
	update_manifest "$temp_config_entry"
}

# backup current sysctl config files
function backup_sysctl_config_files {
	# get the config files data
	ensure_out_file_dir "$(echo "$CONFIG_FILES_OUT_DIR" | sed 's/.$//g')"
	sudo cp -r "/etc/sysctl.d" "$CONFIG_FILES_OUT_DIR"
	# prep the manifest entries
	local config_files_out_dir_name="$(basename "$CONFIG_FILES_OUT_DIR")"
	local config_files_dir_entry='[{"type": "sysctl_d_config_directory", "value": "'$config_files_out_dir_name'"}]'
	local additional_files_array="$(ls "$CONFIG_FILES_OUT_DIR" | jq -R . | jq '. | {"type": "config", "value": ("'$config_files_out_dir_name'/" + .|tostring)}' | jq -s . )"
	update_manifest "$config_files_dir_entry"
	update_manifest "$additional_files_array"
}

# backup current ulimit settings
function backup_ulimit_settings {
	# get the temp config data
	ensure_out_file_dir "$ULIMIT_CONFIG_OUT_FILE"
	local open_file_count_limit="$(ulimit -n)"
	local process_limit="$(ulimit -u)"
	# prep the config content
	config_content='{"process-limit": "'$process_limit'", "open-file-count-limit": "'$open_file_count_limit'"}'
	echo "$config_content" | jq . > "$ULIMIT_CONFIG_OUT_FILE"
	# prep the manifest entry
	local ulimit_entry='[{"type": "ulimit_config", "value": "'"$(basename "$ULIMIT_CONFIG_OUT_FILE")"'"}]'
	update_manifest "$ulimit_entry"
}

# backup everything that is needed
function backup {
	# get the backup data
	backup_manifest
	backup_sysctl_config
	backup_sysctl_config_files
	backup_ulimit_settings
	(($VERBOSITY > 2)) && echo "manifest file - $(cat "$MANIFEST_OUT_FILE")"
	# create the archive
	local extra_args="czf"
	if (($VERBOSITY > 1)); then
		local extra_args+="v"
	fi
	local archive_name="$(basename $OUT_DIR).tgz"
	(($VERBOSITY > 1)) && echo "archiving..."
	tar $extra_args "$archive_name" --directory="$OUT_DIR" ./
	# move the archive if needed
	local extra_args="" # need to unset the extra args because tar is different
	if (($VERBOSITY > 1)); then
		local extra_args="-v"
	fi
	if [ "$(realpath "$archive_name")" != "$ARCHIVE_FILE" ]; then
		(($VERBOSITY > 1)) && echo "moving..."
		mv $extra_args "$archive_name" "$ARCHIVE_FILE"
	fi
	# clean up the data
	(($VERBOSITY > 1)) && echo "cleaning temporary files..."
	sudo rm $extra_args -rf "$OUT_DIR"
}

# list backups
function list_backups {
	if [ ! -d "$BASE_OUT_DIR" ]; then
		echo "no archive directory found" >&2
		exit 0
	fi
	local backup_archives="$(ls -1a "$BASE_OUT_DIR" | grep "^backup-ran-[0-9]*.tgz$" | sort)"
	if [ -z "$backup_archives" ]; then
		echo "no archives found" >&2
		exit 0
	fi
	for i in $backup_archives; do
		local current_file="${BASE_OUT_DIR}${i}"
		echo "$(date -d @$(echo "$current_file" | sed 's/.*-//g; s/.tgz$//g')) - $current_file"
	done
}

# ensure backup
function ensure_backup {
	# find the backup file
	if [ "$RESTORE_ARCHIVE_FILE" == "latest" ]; then
		RESTORE_ARCHIVE_FILE=$(list_backups | tail -n 1 | sed 's#.* - ##g')
		(($VERBOSITY > 0)) && echo "picked $RESTORE_ARCHIVE_FILE as the restore archive file."
	fi
	# ensure the backup file exists
	if [ ! -f "$RESTORE_ARCHIVE_FILE" ]; then
		echo "no valid archive file" >&2
		exit 1
	fi
	# exit if dry run
	if [ "$DRY_RUN" == true ]; then
		echo "would attempt to restore from $RESTORE_ARCHIVE_FILE"
		exit 0
	fi
	# extract the backup
	local extra_args="xf"
	if (($VERBOSITY > 1)); then
		local extra_args+="v"
	fi
	if [ ! -d "$RESTORE_DIR" ]; then
		mkdir "$RESTORE_DIR"
	fi
	tar $extra_args "$RESTORE_ARCHIVE_FILE" --directory="$RESTORE_DIR"
	# test the manifest
	if [ ! -f "$MANIFEST_RESTORE_FILE" ]; then
		echo "manifest file not found at $MANIFEST_RESTORE_FILE from archive $RESTORE_ARCHIVE_FILE" >&2
		exit 1
	fi
	if [[ "$MANIFEST_RESTORE_FILE" =~ \.json$ ]] && [ ! $(jq empty "$MANIFEST_RESTORE_FILE" > /dev/null 2>&1; echo $?) -eq 0 ]; then
		echo "bad manifest file selected at $MANIFEST_RESTORE_FILE" >&2
		jq empty "$MANIFEST_RESTORE_FILE"
		exit 1
	fi
}

# get the selected backup from the archive file
function get_backup_location {
	local backup_location_json=$(jq '.items[] | select(.type=="'$1'")' "$MANIFEST_RESTORE_FILE")
	# check if the selected backup is in the manifest
	if [ -z "$backup_location_json" ]; then
		(($VERBOSITY > 0)) && echo "didn't find a $1 type object in $MANIFEST_RESTORE_FILE"
		echo ""
	else
		local backup_location="${RESTORE_DIR}$(echo "$backup_location_json" | jq -r '.value')"
		# check if the backup in the manifest exists
		if [ ! -f "$backup_location" ] && [ ! -d "$backup_location" ]; then
			echo "backup listed in manifest not found - $backup_location" >&2
			exit 1
		fi
		# if the backup is json, make sure it's valid
		if [[ "$backup_location" =~ \.json$ ]] && [ ! $(jq empty "$backup_location" > /dev/null 2>&1; echo $?) -eq 0 ]; then
			echo "bad json backup file selected at $backup_location" >&2
			jq empty $backup_location
			exit 1
		fi
		# TODO: maybe find a way to validate the temp_config and config_files backups
		echo "$backup_location"
	fi
}

# restore the temp config
function restore_config_backup {
	local config_backup_location="$1"
	# retsore the content
	if (($VERBOSITY > 2)); then
		sudo sysctl -p "$config_backup_location"
	else
		sudo sysctl -p "$config_backup_location" 2>&1 > /dev/null
	fi
}

# restore the config files
function restore_files_backup {
	local files_backup_location="$1"
	if (($VERBOSITY > 0)); then
		local extra_args="-v"
	fi
	ERR=""
	{
		# clean the sysctl.d directory
		sudo mv $extra_args -f /etc/sysctl.d/ /etc/sysctl.d.old/
		sudo cp $extra_args -r "$files_backup_location" /etc/sysctl.d/
		# clean up the old dir if we didn't error out (we should have a back up)
		sudo rm $extra_args -rf /etc/sysctl.d.old/
		# Load the restored configs
		sudo sysctl --load --system
	} || {
		ERR=$?
		(($VERBOSITY > 0)) && echo "errored during restore_files backup, attempting to revert"
		if [ -d "/etc/sysctl.d.old/" ]; then
			sudo rm $extra_args -rf /etc/sysctl.d/
			sudo mv $extra_args -f /etc/sysctl.d.old/ /etc/sysctl.d/
			(($VERBOSITY > 0)) && echo "reverted"
		else
			(($VERBOSITY > 0)) && echo "failed to revert"
		fi
	}
	if [ ! -z "$ERR" ]; then
		echo "error - $ERR" >&2
		exit 1
	fi
}

# backup current ulimit settings
function restore_ulimit_settings_backup {
	local config_backup_location="$1"
	local open_file_count_limit="$(jq -r '."open-file-count-limit"' "$config_backup_location")"
	local process_limit="$(jq -r '."process-limit"' "$config_backup_location")"
	(($VERBOSITY > 0)) && echo "restoring open file count limit to $open_file_count_limit"
	(($VERBOSITY > 0)) && echo "restoring process limit to $process_limit"
	ulimit -n $open_file_count_limit
	ulimit -u $process_limit
}

# restore backup
function restore_backup {
	ensure_backup
	local files_backup_location="$(get_backup_location "sysctl_d_config_directory")"
	local config_backup_location="$(get_backup_location "temp_config")"
	local ulimit_backup_location="$(get_backup_location "ulimit_config")"

	# files has to be first because it will require a reload of values once it comes back up
	if [ ! -z "$files_backup_location" ]; then
		(($VERBOSITY > 0)) && echo "starting file restore"
		# TODO: interactive confirm?
		restore_files_backup "$files_backup_location"
	fi

	if [ ! -z "$config_backup_location" ]; then
		(($VERBOSITY > 0)) && echo "starting config restore"
		# TODO: interactive confirm?
		restore_config_backup "$config_backup_location"
	fi

	if [ ! -z "$config_backup_location" ]; then
		(($VERBOSITY > 0)) && echo "starting ulimit restore"
		# TODO: interactive confirm?
		restore_ulimit_settings_backup "$ulimit_backup_location"
	fi
}

# opens an archive file with the --open-command
function open_file {
	if [ "$OPEN_FILE" == "latest" ]; then
		OPEN_FILE=$(list_backups | tail -n 1 | sed 's#.* - ##g')
		(($VERBOSITY > 0)) && echo "picked $OPEN_FILE as the open file."
	fi
	if [ ! -f "$OPEN_FILE" ]; then
		echo "open file not found..." >&2
		exit 1
	fi
	OPEN_COMMAND=$(echo "$OPEN_COMMAND" | sed 's#\$OPEN_FILE#'$OPEN_FILE'#g')
	(($VERBOSITY > 1)) && echo "running the open command - $OPEN_COMMAND"
	eval "$OPEN_COMMAND"
	exit 0
}

# sets a sysctl d setting
function set_sysctl_d_setting {
	local setting_name="$1"
	local setting_value="$2"
	local update_content="$setting_name=$setting_value"
	(($VERBOSITY > 0)) && echo "updating $setting_name to $setting_value"
	if [ $PERSIST = true ]; then
		local file_name="/etc/sysctl.d/$(echo "$setting_name" | sed 's/\./-/g').conf"
		if [ "$DRY_RUN" == true ]; then
			echo "Would be writing $update_content to $file_name"
		else
			echo "$update_content" | sudo tee -a $file_name
		fi
	else
		if [ "$DRY_RUN" == true ]; then
			echo "Would be running \`sudo sysctl -w $update_content\`"
		else
			sudo sysctl -w $update_content
		fi
	fi
}

# sets a ulimit setting
function set_ulimit_setting {
	local setting_flag="$1"
	local setting_value="$2"
	local command="ulimit -$setting_flag $setting_value"
	(($VERBOSITY > 0)) && echo "updating ulimit -$setting_flag to $setting_value"
	if [ "$DRY_RUN" == true ]; then
		echo "Would have run \`$command\`"
	else
		eval "$command"
	fi
}

# reloads the system configuration
function reload_configuration {
	if [ "$DRY_RUN" == true ]; then
		echo "would be reloading updated configuration"
	else
		sudo sysctl --load --system
	fi
}

#
# CLI parsing
#
PARAMS=""
while (("$#")); do
	case "$1" in
	--open-command)
		if [ -n "$2" ] && [ "${2:0:1}" != "-" ]; then
			OPEN_COMMAND="$2"
			shift 2
		else
			# the default is set as a global
			shift 1
		fi
		;;
	# the archive file, optional argument
	--out)
		if [ -n "$2" ] && [ "${2:0:1}" != "-" ]; then
			ARCHIVE_FILE=$2
			shift 2
		else
			echo "Error: Argument for $1 is missing" >&2
			help
			exit 1
		fi
		;;
	# the open file, optional argument
	-o | --open)
		if [ -n "$2" ] && [ "${2:0:1}" != "-" ]; then
			OPEN_FILE="$2"
			shift 2
		else
			OPEN_FILE="latest"
			shift 1
		fi
		;;
	# restore archive file, optional argument
	-r | --restore)
		if [ -n "$2" ] && [ "${2:0:1}" != "-" ]; then
			RESTORE_ARCHIVE_FILE=$2
			shift 2
		else
			RESTORE_ARCHIVE_FILE="latest"
			shift 1
		fi
		;;
	# config out file, optional argument
	-b | --backup-only)
		BACKUP_ONLY=true
		shift
		;;
	# config out file, optional argument
	-c | --clean)
		SHOULD_CLEAN=true
		shift
		;;
	# dry-run, optional argument
	-d | --dry-run)
		DRY_RUN=true
		shift
		;;
	# help flag
	-h | --help)
		SHOW_HELP=true
		shift
		;;
	# list flag
	-l | --list)
		SHOULD_LIST=true
		shift
		;;
	# persist flag
	-p | --persist)
		PERSIST=true
		shift
		;;
	# verbosity multi-flag
	-v | --verbose)
		((VERBOSITY+=1))
		shift
		;;
	# unsupported flags
	-* | --*=)
		echo "Error: Unsupported flag $1" >&2
		help
		exit 1
		;;
	# preserve positional arguments
	*)
		PARAMS="$PARAMS $1"
		shift
		;;
	esac
done

#
# Do the work
#
[ $SHOW_HELP == true ] && help && exit 0
[ $SHOULD_LIST == true ] && list_backups && exit 0
[ $SHOULD_CLEAN == true ] && clean_backups && exit 0
[ ! -z "$RESTORE_ARCHIVE_FILE" ] && restore_backup && exit 0
[ ! -z "$OPEN_FILE" ] && open_file && exit 0

backup
[ $BACKUP_ONLY == true ] && exit 0

# Needed by ECK for OOM errors
# raise the max memory map count per process
set_sysctl_d_setting "vm.max_map_count" "$TARGET_VM_MAX_MAP_COUNT"

# Needed by Sonarqube
# Sets the max file handles that Linux will allocate
set_sysctl_d_setting "fs.file-max" "$TARGET_FS_FILE_MAX"
# Raise the open file count limit
set_ulimit_setting "n" "$TARGET_OPEN_FILE_COUNT_LIMIT"
# Raise the process limit
set_ulimit_setting "u" "$TARGET_PROCESS_LIMIT"

reload_configuration

# Preload kernel modules, required by istio-init running on SELinux enforcing instances
# sudo modprobe xt_REDIRECT
# sudo modprobe xt_owner
# sudo modprobe xt_statistic

# Persist kernel modules settings after reboots
# printf "xt_REDIRECT\nxt_owner\nxt_statistic\n" | sudo tee -a /etc/modules

# Kubernetes requires swap disabled
# Turn off all swap devices and files (won't last reboot)
# sudo swapoff -a

# For swap to stay off, you can remove any references found via
# cat /proc/swaps
# cat /etc/fstab
