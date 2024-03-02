#! /usr/bin/env bash

#
# Environment Validation
#
validation="$(environment-validation -l "big-bang" -l "core" 2>&1)"
if [ ! -z "$validation" ]; then
	echo "Validation error:" >&2
	echo "$validation" >&2
	exit 1
fi

# Steps adapted from https://github.com/DoD-Platform-One/big-bang/blob/master/docs/guides/deployment-scenarios/quickstart.md#step-4-configure-host-operating-system-prerequisites

set -e
trap 'echo ❌ exit at ${0}:${LINENO}, command was: ${BASH_COMMAND} 1>&2' ERR

#
# global defaults
#
BACKUP_ONLY=${BASIC_SETUP_BIG_BANG_OS_PREP_BACKUP_ONLY:-""}
BASE_OUT_DIR=${BASIC_SETUP_BIG_BANG_OS_PREP_BASE_OUT_DIR:-""}
DRY_RUN=${BASIC_SETUP_BIG_BANG_OS_PREP_DRY_RUN:-""}
FORCE=${BASIC_SETUP_BIG_BANG_OS_PREP_FORCE:-""}
OPEN_FILE=${BASIC_SETUP_BIG_BANG_OS_PREP_OPEN_FILE:-""}
PERSIST=${BASIC_SETUP_BIG_BANG_OS_PREP_PERSIST:-""}
RESTORE_ARCHIVE_FILE=${BASIC_SETUP_BIG_BANG_OS_PREP_RESTORE_ARCHIVE_FILE:-""}
SHOULD_CLEAN=${BASIC_SETUP_BIG_BANG_OS_PREP_SHOULD_CLEAN:-""}
SHOW_HELP=false
SHOULD_LIST=${BASIC_SETUP_BIG_BANG_OS_PREP_SHOULD_LIST:-""}
TARGET_FS_FILE_MAX=${BASIC_SETUP_BIG_BANG_OS_PREP_TARGET_FS_FILE_MAX:-""}
TARGET_OPEN_FILE_COUNT_LIMIT=${BASIC_SETUP_BIG_BANG_OS_PREP_TARGET_OPEN_FILE_COUNT_LIMIT:-""}
TARGET_PROCESS_LIMIT=${BASIC_SETUP_BIG_BANG_OS_PREP_TARGET_PROCESS_LIMIT:-""}
TARGET_VM_MAX_MAP_COUNT=${BASIC_SETUP_BIG_BANG_OS_PREP_TARGET_VM_MAX_MAP_COUNT:-""}
VERBOSITY=${BASIC_SETUP_VERBOSITY:--1}

# TODO: offer a way to pass in additional modules
TARGET_MODULUES=(
	"br_netfilter" # suze docs - https://www.suse.com/support/kb/doc/?id=000020241
	"nf_nat_redirect" # suze docs
	"xt_REDIRECT" # both
	"xt_owner" # both
	"xt_statistic" # big bang docs - listed on line 3
)

#
# load environment variables
#
. basic-setup-set-env || true

#
# computed values (often can't be alphabetical)
#
if [ -z "$BACKUP_ONLY" ]; then
	BACKUP_ONLY=${BASIC_SETUP_BIG_BANG_OS_PREP_BACKUP_ONLY:-false}
fi
if [ -z "$BASE_OUT_DIR" ]; then
	BASE_OUT_DIR=${BASIC_SETUP_BIG_BANG_OS_PREP_BASE_OUT_DIR:-"$HOME/.basic-setup/big-bang/os-prep/"}
fi
if [ -z "$DRY_RUN" ]; then
	DRY_RUN=${BASIC_SETUP_BIG_BANG_OS_PREP_DRY_RUN:-false}
fi
if [ -z "$FORCE" ]; then
	FORCE=${BASIC_SETUP_BIG_BANG_OS_PREP_FORCE:-false}
fi
if [ -z "$OPEN_FILE" ]; then
	OPEN_FILE=${BASIC_SETUP_BIG_BANG_OS_PREP_OPEN_FILE:-""}
fi
if [ -z "$PERSIST" ]; then
	PERSIST=${BASIC_SETUP_BIG_BANG_OS_PREP_PERSIST:-false}
fi
if [ -z "$RESTORE_ARCHIVE_FILE" ]; then
	RESTORE_ARCHIVE_FILE=${BASIC_SETUP_BIG_BANG_OS_PREP_RESTORE_ARCHIVE_FILE:-""}
fi
if [ -z "$SHOULD_CLEAN" ]; then
	SHOULD_CLEAN=${BASIC_SETUP_BIG_BANG_OS_PREP_SHOULD_CLEAN:-false}
fi
if [ -z "$SHOULD_LIST" ]; then
	SHOULD_LIST=${BASIC_SETUP_BIG_BANG_OS_PREP_SHOULD_LIST:-false}
fi
if [ -z "$TARGET_FS_FILE_MAX" ]; then
	TARGET_FS_FILE_MAX=${BASIC_SETUP_BIG_BANG_OS_PREP_TARGET_FS_FILE_MAX:-131072}
fi
if [ -z "$TARGET_OPEN_FILE_COUNT_LIMIT" ]; then
	TARGET_OPEN_FILE_COUNT_LIMIT=${BASIC_SETUP_BIG_BANG_OS_PREP_TARGET_OPEN_FILE_COUNT_LIMIT:-131072}
fi
if [ -z "$TARGET_PROCESS_LIMIT" ]; then
	TARGET_PROCESS_LIMIT=${BASIC_SETUP_BIG_BANG_OS_PREP_TARGET_PROCESS_LIMIT:-8192}
fi
if [ -z "$TARGET_VM_MAX_MAP_COUNT" ]; then
	TARGET_VM_MAX_MAP_COUNT=${BASIC_SETUP_BIG_BANG_OS_PREP_TARGET_VM_MAX_MAP_COUNT:-524288}
fi
if (( $VERBOSITY == -1 )); then
	VERBOSITY=${BASIC_SETUP_VERBOSITY:-0}
fi
HAS_SYSTEMCTL="$( (( $(command -v systemctl >/dev/null 2>&1; echo $?) == 0 )) && echo true || echo false )"
RUN_TIMESTAMP="$(date +%s)"
OPEN_COMMAND="t=\"/tmp/$RUN_TIMESTAMP/\"; mkdir -p \$t; tar xf \"\$OPEN_FILE\" --directory=\$t; code \$t"
OUT_DIR="${BASE_OUT_DIR}backup-ran-${RUN_TIMESTAMP}/"
ARCHIVE_FILE="$(echo "$OUT_DIR" | sed 's/.$//').tgz"
CONFIG_FILES_OUT_DIR="${OUT_DIR}sysctl-d-backup/"
MANIFEST_OUT_FILE="${OUT_DIR}manifest.json"
MANIFEST_RESTORE_FILE="${RESTORE_DIR}manifest.json"
MODULE_SETTINGS_OUT_FILE="${OUT_DIR}modules-backup"
RESTORE_DIR="${BASE_OUT_DIR}restore-ran-${RUN_TIMESTAMP}/"
SWAP_FSTAB_OUT_FILE="${OUT_DIR}swap-fstab-backup"
SWAP_SETTINGS_OUT_FILE="${OUT_DIR}swap-settings.json"
TEMP_CONFIG_OUT_FILE="${OUT_DIR}sysctl-temp-config-backup.conf"
ULIMIT_CONFIG_OUT_FILE="${OUT_DIR}ulimit-config-backup.json"

# TODO: finish the other setup steps
# for updating the sudoers - https://stackoverflow.com/questions/10420713/regex-pattern-to-edit-etc-sudoers-file

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
		description: Prepares the OS for running Big Bang - https://github.com/DoD-Platform-One/big-bang/blob/master/docs/guides/deployment-scenarios/quickstart.md#step-4-configure-host-operating-system-prerequisites
		----------
		-b|--backup-only - (flag, current: $BACKUP_ONLY) Exit after backup, also set with \`BASIC_SETUP_BIG_BANG_OS_PREP_BACKUP_ONLY\`.
		-c|--clean       - (flag, current: $SHOULD_CLEAN) Delete everything in $BASE_OUT_DIR and exit, also set with \`BASIC_SETUP_BIG_BANG_OS_PREP_SHOULD_CLEAN\`.
		-d|--dry-run     - (flag, current: $DRY_RUN) Writes out deletes and updates, still creates (not restores) backups, also set with \`BASIC_SETUP_BIG_BANG_OS_PREP_DRY_RUN\`.
		-f|--force       - (flag, current: $FORCE) Skip all confirmations, also set with \`BASIC_SETUP_BIG_BANG_OS_PREP_FORCE\`.
		-h|--help        - (flag, current: $SHOW_HELP) Print this help message and exit
		-l|--list        - (flag, current: $SHOULD_LIST) Print the possible restore points and exit, also set with \`BASIC_SETUP_BIG_BANG_OS_PREP_SHOULD_LIST\`.
		-o|--open        - (optional, current: "$OPEN_FILE") Runs from archive to run the --open-command against and exit, if used as a flag it will use latest, also set with \`BASIC_SETUP_BIG_BANG_OS_PREP_OPEN_FILE\`.
		-p|--persist     - (flag, current: $PERSIST) Persist the changes through a restart (write files), also set with \`BASIC_SETUP_BIG_BANG_OS_PREP_PERSIST\`.
		-r|--restore     - (optional, current: "$RESTORE_ARCHIVE_FILE") Runs from archive to restore settings from and exit, if used as a flag it will use latest, also set with \`BASIC_SETUP_BIG_BANG_OS_PREP_RESTORE_ARCHIVE_FILE\`.
		-v|--verbose     - (multi-flag, current: $VERBOSITY) Increase the verbosity by 1, also set with \`BASIC_SETUP_VERBOSITY\`.
		--open-command   - (optional, default: "$OPEN_COMMAND") The command to run with -o. \$OPEN_FILE will be replaced by -o, also set with \`BASIC_SETUP_BIG_BANG_OS_PREP_OPEN_COMMAND\`.
		--out            - (optional, current: "$ARCHIVE_FILE") Absolute path of out archive, also set with \`BASIC_SETUP_BIG_BANG_OS_PREP_ARCHIVE_FILE\`.
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
	if [ ! -d "$BASE_OUT_DIR" ]; then
		(($VERBOSITY > 0)) && echo "no backup folder found, exiting..."
		exit 0
	fi
	local extra_args=""
	if (($VERBOSITY > 0)); then
		local extra_args="-v"
	fi
	if (( $(ls $BASE_OUT_DIR | wc -l) > 0 )); then
		if (($VERBOSITY > 0)); then
			echo "found files, cleaning..."
			echo "would remove the following:"
			echo "$BASE_OUT_DIR"
			general-ls-recursive "$BASE_OUT_DIR"
		fi
		if [ "$DRY_RUN" == true ]; then
			exit 0
		else
			if [ "$FORCE" == true ] || [ "$(general-interactive-confirm)" == true ]; then
				sudo rm $extra_args -rf $BASE_OUT_DIR
			fi
		fi
		exit 0
	else
		(($VERBOSITY > 0)) && echo "found no files, exiting..."
		exit 0
	fi
}

# get active swap devices
function get_active_swap_devices {
	swapon -s | awk '{print $1}' | tail -n +2
}

# get systemctl swap devices
function get_systemctl_swap_devices {
	if [ "$HAS_SYSTEMCTL" == true ]; then
		local target_state="$1"
		if [ ! -z "$target_state" ]; then
			local target_state="--state=$target_state"
		fi
		local systemctl_output="$(systemctl --type=swap $target_state | tail -n +2)"
		# skip if no swap units loaded
		if (( $(echo "$systemctl_output" | grep "^\s*0" >/dev/null 2>&1; echo $?) == 0 )); then
			return 0
		fi
		# get only the lines that have units
		local list_of_swap_devices="$(echo "$systemctl_output" | awk -v 'RS=\n\n' '1;{exit}')"
		# remove characters until the first alpha character, then print the first item (unit name)
		echo "$list_of_swap_devices" | sed 's/^[^[:alpha:]]//' | awk '{print $1}'
	else
		return 0
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
	# get the ulimit data
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

# backup current module settings
function backup_module_settings {
	# get the modules data
	ensure_out_file_dir "$MODULE_SETTINGS_OUT_FILE"
	sudo cp "/etc/modules" "$MODULE_SETTINGS_OUT_FILE"
	# prep the manifest entry
	local modules_entry='[{"type": "modules_file", "value": "'"$(basename "$MODULE_SETTINGS_OUT_FILE")"'"}]'
	update_manifest "$modules_entry"
}

# backup current swap settings
function backup_swap_settings {
	# get the modules data
	ensure_out_file_dir "$SWAP_SETTINGS_OUT_FILE"
	local swap_array="$(get_active_swap_devices | jq -R . | jq -s .)"
	if [ "$HAS_SYSTEMCTL" == true ]; then
		local swap_systemctl_devices="$(get_systemctl_swap_devices | jq -R . | jq -s .)"
	fi
	swap_backup_content="$(
		cat <<- EOF
			{
				$( [ "$HAS_SYSTEMCTL" == true ] && echo '"systemctl_swap_devices": '"$swap_systemctl_devices"',' || echo "")
				"active_swap_devices": $swap_array
			}
		EOF
	)"
	echo "$swap_backup_content" | jq . > "$SWAP_SETTINGS_OUT_FILE"
	sudo cp /etc/fstab "$SWAP_FSTAB_OUT_FILE"
	local swap_files_entry='[{"type": "swap_fstab_file", "value": "'"$(basename "$SWAP_FSTAB_OUT_FILE")"'"}]'
	local swap_entry='[{"type": "swap_devices_file", "value": "'"$(basename "$SWAP_SETTINGS_OUT_FILE")"'"}]'
	update_manifest "$(echo "$swap_files_entry" | jq .)"
	update_manifest "$(echo "$swap_entry" | jq .)"
}

# backup everything that is needed
function backup {
	# get the backup data
	backup_manifest
	backup_sysctl_config
	backup_sysctl_config_files
	backup_ulimit_settings
	backup_module_settings
	backup_swap_settings
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
	[ "$DRY_RUN" == true ] && local dry_run_info=" as a dry run"
	(($VERBOSITY > 0)) && echo "this would attempt to restore from ${RESTORE_ARCHIVE_FILE}${dry_run_info}"
	if [ "$(general-interactive-confirm)" == false ]; then
		(($VERBOSITY > 0)) && echo "no restore archive, exiting..."
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
		# TODO: validate other file types that will be in there (.config, fstab, modules)
		echo "$backup_location"
	fi
}

# restore the temp config
function restore_config_backup {
	local config_backup_location="$1"
	(($VERBOSITY > 0)) && echo "this will run 'sysctl -p' with '$config_backup_location'"
	if [ "$DRY_RUN" == true ] || { [ "$FORCE" == false ] && [ "$(general-interactive-confirm)" == false ]; }; then
		(($VERBOSITY > 0)) && echo "skipping 'sysctl -p' restore..."
		return 0
	fi
	# retsore the content
	if (($VERBOSITY > 2)); then
		sudo sysctl -p "$config_backup_location"
	else
		sudo sysctl -p "$config_backup_location" >/dev/null 2>&1
	fi
}

# restore the config files
function restore_files_backup {
	local files_backup_location="$1"
	if (($VERBOSITY > 0)); then
		local extra_args="-v"
		echo "this would replace '/etc/sysctl.d/' with '$files_backup_location'"
	fi
	if [ "$DRY_RUN" == true ] || { [ "$FORCE" == false ] && [ "$(general-interactive-confirm)" == false ]; }; then
		(($VERBOSITY > 0)) && echo "skipping '/etc/sysctl.d/' restore..."
		return 0
	fi
	ERR=""
	{
		# clean the sysctl.d directory
		sudo mv $extra_args -f /etc/sysctl.d/ /etc/sysctl.d.old/
		sudo cp $extra_args -r "$files_backup_location" /etc/sysctl.d/
		# clean up the old dir if we didn't error out (we should have a back up)
		sudo rm $extra_args -rf /etc/sysctl.d.old/
		reload_configuration
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
		echo "error restoring /etc/sysctl.d files - $ERR" >&2
		exit 1
	fi
}

# restore current ulimit settings
function restore_ulimit_settings_backup {
	local config_backup_location="$1"
	local open_file_count_limit="$(jq -r '."open-file-count-limit"' "$config_backup_location")"
	local process_limit="$(jq -r '."process-limit"' "$config_backup_location")"
	if (($VERBOSITY > 0)); then
		echo "this would restore open file count limit to $open_file_count_limit"
		echo "and restore process limit to $process_limit"
	fi
	if [ "$DRY_RUN" == true ] || { [ "$FORCE" == false ] && [ "$(general-interactive-confirm)" == false ]; }; then
		(($VERBOSITY > 0)) && echo "skipping ulimit restores..."
		return 0
	fi
	ulimit -n $open_file_count_limit
	ulimit -u $process_limit
}

# restore the modules file
function restore_module_settings_backup {
	local module_backup_location="$1"
	(($VERBOSITY > 0)) && echo "this would replace '/etc/modules' with $module_backup_location"
	if (($VERBOSITY > 0)); then
		local extra_args="-v"
	fi
	if [ "$DRY_RUN" == true ] || { [ "$FORCE" == false ] && [ "$(general-interactive-confirm)" == false ]; }; then
		(($VERBOSITY > 0)) && echo "skipping the modules file restore..."
		return 0
	fi
	ERR=""
	{
		# clean the modules directory
		sudo mv $extra_args -f /etc/modules /etc/modules.old
		sudo cp $extra_args "$module_backup_location" /etc/modules
		if [[ "$(cat /etc/modules.old)" != "$(cat /etc/modules)" ]]; then
			echo "modules modified, please restart..."
		fi
		# clean up the old dir if we didn't error out (we should have a back up)
		sudo rm $extra_args -f /etc/modules.old
	} || {
		ERR=$?
		echo "modules may modified, please restart..."
		(($VERBOSITY > 0)) && echo "errored during restore modules settings backup, attempting to revert"
		if [ -d "/etc/modules.old" ]; then
			sudo rm $extra_args -f /etc/modules
			sudo mv $extra_args -f /etc/modules.old /etc/modules
			(($VERBOSITY > 0)) && echo "reverted"
		else
			(($VERBOSITY > 0)) && echo "failed to revert"
		fi
	}
	if [ ! -z "$ERR" ]; then
		echo "error restoring /etc/modules file - $ERR" >&2
		exit 1
	fi
}

# restore current swap settings
function restore_swap_settings_backup {
	local swap_devices_backup_location="$1"
	local swap_fstab_backup_location="$2"
	local swap_devices="$(jq -r '.active_swap_devices[]' "$swap_devices_backup_location")"
	if [ "$HAS_SYSTEMCTL" == true ]; then
		local swap_systemctl_devices="$(jq -r '.systemctl_swap_devices[]' "$swap_devices_backup_location")"
	fi
	if (($VERBOSITY > 0)); then
		echo "this would restore the swap devices - $(echo $swap_devices | sed 's/\n/\, /g')"
		echo "and replace 'etc/fstab' with $swap_fstab_backup_location"
		[ ! -z "$swap_systemctl_devices" ] && echo "and unmask the systemctl managed swap devices - $(echo $swap_systemctl_devices | sed 's/\n/\, /g')"
	fi
	if [ "$DRY_RUN" == true ] || { [ "$FORCE" == false ] && [ "$(general-interactive-confirm)" == false ]; }; then
		(($VERBOSITY > 0)) && echo "skipping the swap settings restore..."
		return 0
	fi
	for i in $swap_devices; do
		(($VERBOSITY > 0)) && echo "restoring swap device $i"
		if [[ "$(get_active_swap_devices)" =~ $i ]]; then
			(($VERBOSITY > 0)) && echo "swap device $i already active"
		else
			sudo swapon "$i"
		fi
	done
	if [ ! -z "$swap_fstab_backup_location" ] && [ -f "$swap_fstab_backup_location" ]; then
		(($VERBOSITY > 0)) && echo "restoring /etc/fstab"
		sudo mv -f "$swap_fstab_backup_location" /etc/fstab
	fi
	if [ "$HAS_SYSTEMCTL" == true ]; then
		local masked_devices="$(get_systemctl_swap_devices "masked")"
		for i in $swap_systemctl_devices; do
			(($VERBOSITY > 0)) && echo "restoring swap systemctl device $i"
			if [[ "$(get_systemctl_swap_devices "loaded")" =~ $i ]]; then
				(($VERBOSITY > 0)) && echo "systemctl swap device $i already active"
			else
				if [[ "$masked_devices" =~ $i ]]; then
					(($VERBOSITY > 1)) && echo "unmasking systemctl swap device $i"
					sudo systemctl unmask $i
				else
					(($VERBOSITY > 0)) && echo "systemctl swap device $i not masked"
				fi
			fi
		done
	fi
	if [ ! -z "$swap_fstab_backup_location" ] && [ -f "$swap_fstab_backup_location" ]; then
		(($VERBOSITY > 0)) && echo "restoring /etc/fstab"
		sudo mv -f "$swap_fstab_backup_location" /etc/fstab
	fi
}

# restore backup
function restore_backup {
	ensure_backup

	local files_backup_location="$(get_backup_location "sysctl_d_config_directory")"
	if [ ! -z "$files_backup_location" ]; then
		(($VERBOSITY > 0)) && echo "starting file restore"
		restore_files_backup "$files_backup_location"
	fi

	local config_backup_location="$(get_backup_location "temp_config")"
	if [ ! -z "$config_backup_location" ]; then
		(($VERBOSITY > 0)) && echo "starting config restore"
		restore_config_backup "$config_backup_location"
	fi

	local ulimit_backup_location="$(get_backup_location "ulimit_config")"
	if [ ! -z "$ulimit_backup_location" ]; then
		(($VERBOSITY > 0)) && echo "starting ulimit restore"
		restore_ulimit_settings_backup "$ulimit_backup_location"
	fi

	local module_backup_location="$(get_backup_location "modules_file")"
	if [ ! -z "$module_backup_location" ]; then
		(($VERBOSITY > 0)) && echo "starting module restore"
		restore_module_settings_backup "$module_backup_location"
	fi

	local swap_backup_location="$(get_backup_location "swap_devices_file")"
	local swap_fstab_backup_location="$(get_backup_location "swap_fstab_file")"
	if [ ! -z "$swap_backup_location" ]; then
		(($VERBOSITY > 0)) && echo "starting swap devices and files restore"
		restore_swap_settings_backup "$swap_backup_location" "$swap_fstab_backup_location"
	fi

	(($VERBOSITY > 0)) && echo "this will clean up by removing $RESTORE_DIR"
	if [ "$FORCE" == true ] || [ "$(general-interactive-confirm)" == true ]; then
		local extra_args=""
		if (($VERBOSITY > 0)); then
			echo "starting clean up..."
			local extra_args="-v"
		fi
		rm -rf $extra_args "$RESTORE_DIR"
	else
		(($VERBOSITY > 0)) && echo "skipping clean up"
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
	local persist_string=" temporarily"
	[ "$PERSIST" == true ] && persist_string=" in the configuration files"
	(($VERBOSITY > 0)) && echo "this would update $setting_name to ${setting_value}${persist_string}"
	if [ "$DRY_RUN" == true ] || { [ "$FORCE" == false ] && [ "$(general-interactive-confirm)" == false ]; }; then
		(($VERBOSITY > 0)) && echo "skipping the update $setting_name to $setting_value..."
		return 0
	fi
	if [ $PERSIST = true ]; then
		local file_name="/etc/sysctl.d/$(echo "$setting_name" | sed 's/\./-/g').conf"
		# overwrite rather than append if it's for specific settings
		echo "$update_content" | sudo tee $file_name > /dev/null
	else
		sudo sysctl -w $update_content
	fi
}

# sets a ulimit setting
function set_ulimit_setting {
	local setting_flag="$1"
	local setting_value="$2"
	local command="ulimit -$setting_flag $setting_value"
	(($VERBOSITY > 0)) && echo "updating ulimit -$setting_flag to $setting_value"
	if [ "$DRY_RUN" == true ] || { [ "$FORCE" == false ] && [ "$(general-interactive-confirm)" == false ]; }; then
		(($VERBOSITY > 0)) && echo "skipping the ulimit update of $setting_flag to $setting_value..."
		return 0
	fi
	eval "$command"
}

# reloads the system configuration
function reload_configuration {
	(($VERBOSITY > 0)) && echo "this would reload the system configuration"
	if [ "$DRY_RUN" == true ] || { [ "$FORCE" == false ] && [ "$(general-interactive-confirm)" == false ]; }; then
		(($VERBOSITY > 0)) && echo "skipping the reload of the system configuration..."
		return 0
	else
		sudo sysctl --load --system
	fi
}

# set up modules, or skip if not using SELinux
function set_modules {
	# Test if we are using SELinux
	if (( $(command -v getenforce >/dev/null 2>&1; echo $?) == 0 )); then
		local persist_string=""
		[ "$PERSIST" == true ] && persist_string=" and persist them in the configuration files"
		(($VERBOSITY > 0)) && echo "this would enable the modules (${TARGET_MODULUES[@]})${persist_string}"
		if [ "$DRY_RUN" == true ] || { [ "$FORCE" == false ] && [ "$(general-interactive-confirm)" == false ]; }; then
			(($VERBOSITY > 0)) && echo "skipping the module updates for (${TARGET_MODULUES[@]})..."
			return 0
		fi
		for i in "${TARGET_MODULUES[@]}"; do
			# Test if the module is already loaded
			if (( $(lsmod | grep "^$i\s*" >/dev/null 2>&1; echo ?) == 0)); then
				(($VERBOSITY > 0)) && echo "module already in \`lsmod\`"
			else
				sudo modprobe $i
			fi
			if [ "$PERSIST" == true ]; then
				# Test if the module is already in /etc/modules
				if (( $(grep $i /etc/modules >/dev/null 2>&1; echo ?) == 0)); then
					(($VERBOSITY > 0)) && echo "module already in /etc/modules"
				else
					echo "$i" | sudo tee -a /etc/modules > /dev/null
				fi
			fi
		done
	else
		(($VERBOSITY > 0)) && echo "SELinux not found, skipping module modifications" || return 0
	fi
}

# turn off swap devices
function set_swap_devices_off {
	local new_fstab_content=$(cat /etc/fstab | sed 's!\(.* swap .*\)!# \1!g')
	local systemctl_devices=""
	if [ "$HAS_SYSTEMCTL" == true ]; then
		local systemctl_devices="$(get_systemctl_swap_devices)"
	fi
	if (($VERBOSITY > 0)); then
		echo "this would have run sudo swapoff -a"
		if [ "$PERSIST" == true ]; then
			echo "Would have modified /etc/fstab to the following:"
			echo "--"
			echo "$new_fstab_content"
			echo "--"
			for i in $systemctl_devices; do
				echo "Would have run sudo systemctl mask $i"
			done
		fi
	fi
	if [ "$DRY_RUN" == true ] || { [ "$FORCE" == false ] && [ "$(general-interactive-confirm)" == false ]; }; then
		(($VERBOSITY > 0)) && echo "skipping the swap updates..."
		return 0
	fi
	sudo swapoff -a
	echo "$new_fstab_content" | sudo tee /etc/fstab > /dev/null
	for i in $systemctl_devices; do
		sudo systemctl mask $i
	done
}

#
# CLI parsing
#
PARAMS=""
while (("$#")); do
	case "$1" in
	# backup flag
	-b | --backup-only)
		BACKUP_ONLY=true
		shift
		;;
	# clean flag
	-c | --clean)
		SHOULD_CLEAN=true
		shift
		;;
	# dry-run flag
	-d | --dry-run)
		DRY_RUN=true
		shift
		;;
	# force flag
	-f | --force)
		FORCE=true
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
	# the file to open, optional argument
	--open-command)
		if [ -n "$2" ] && [ "${2:0:1}" != "-" ]; then
			OPEN_COMMAND="$2"
			shift 2
		else
			OPEN_COMMAND="latest"
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
	# persist flag
	-p | --persist)
		PERSIST=true
		shift
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
	# verbosity multi-flag
	-v | --verbose)
		((VERBOSITY+=1))
		shift
		;;
	# unsupported flags and arguments
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

# Need by Istio if using SELinux
# Preload kernel modules
set_modules

# Needed by Kubernetes
# Turn off all swap devices and files
set_swap_devices_off
