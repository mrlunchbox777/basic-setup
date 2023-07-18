#! /usr/bin/env bash

# Steps adapted from https://github.com/DoD-Platform-One/big-bang/blob/master/docs/guides/deployment-scenarios/quickstart.md#step-4-configure-host-operating-system-prerequisites

set -e
trap 'echo ❌ exit at ${0}:${LINENO}, command was: ${BASH_COMMAND} 1>&2' ERR

#
# constants
#
OUT_FILE_TIMESTAMP="$(date +%s)"
OUT_FILE_PREFIX="os-prep"
ORIGINAL_OUT_DIR="$HOME/.basic-setup/big-bang/"
ORIGINAL_CONFIG_OUT_FILE="${ORIGINAL_OUT_DIR}${OUT_FILE_PREFIX}-sysctl-config-backup-$OUT_FILE_TIMESTAMP.conf"
ORIGINAL_FILES_OUT_FILE="${ORIGINAL_OUT_DIR}${OUT_FILE_PREFIX}-sysctl-d-backup-$OUT_FILE_TIMESTAMP.json"
ORIGINAL_MANIFEST_OUT_FILE="${ORIGINAL_OUT_DIR}${OUT_FILE_PREFIX}-manifest-$OUT_FILE_TIMESTAMP.json"

#
# global defaults
#
CONFIG_OUT_FILE="$ORIGINAL_CONFIG_OUT_FILE"
FILES_OUT_FILE="$ORIGINAL_FILES_OUT_FILE"
MANIFEST_OUT_FILE="$ORIGINAL_MANIFEST_OUT_FILE"
PERSIST=false
RESTORE_MANIFEST_FILE=""
SHOULD_CLEAN=false
SHOULD_LIST=false
SHOW_HELP=false
VERBOSITY=0

#
# helper functions
#

# script help message
function help {
	# TODO: add open
	command_for_help="$(basename "$0")"
	cat <<- EOF
		----------
		usage: $command_for_help <arguments>
		----------
		-c|--clean          - (flag, default: false) Deletes the files that match ${ORIGINAL_OUT_DIR}${OUT_FILE_PREFIX}* and exit.
		-h|--help           - (flag, default: false) Print this help message and exit.
		-l|--list           - (flag, default: false) Print the possible restore points and exit.
		-p|--persist        - (flag, default: false) Persist the changes through a restart (write files).
		-r|--restore        - (optional, default: "") Absolute path of manifest file to restore settings from. Will not perform regular setup. Pass "latest" to restore from latest manifest file.
		-v|--verbose        - (multi-flag, default: 0) increase the verbosity by 1.
		--config-out-file   - (optional, default: "$ORIGINAL_CONFIG_OUT_FILE" (suffix is Unix time)) Absolute path of config out file.
		--files-out-file    - (optional, default: "$ORIGINAL_FILES_OUT_FILE" (suffix is Unix time)) Absolute path of sysctl.d files out file.
		--manifest-out-file - (optional, default: "$ORIGINAL_MANIFEST_OUT_FILE" (suffix is Unix time)) Absolute path of manifest out file.
		----------
		examples:
		setup                 - $command_for_help -v
		clean backups         - $command_for_help -v -c
		restore latest backup - $command_for_help -v -r latest
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
	extra_args=""
	if (($VERBOSITY > 0)); then
		extra_args="-v"
	fi
	if (( $(ls $ORIGINAL_OUT_DIR | wc -l) > 0 )); then
		(($VERBOSITY > 0)) && echo "found files, cleaning..."
		rm $extra_args $(ls $ORIGINAL_OUT_DIR | grep "$OUT_FILE_PREFIX" | xargs -I % -- echo "${ORIGINAL_OUT_DIR}%")
	fi
}

# backup current sysctl config
function backup_sysctl_config {
	ensure_out_file_dir "$CONFIG_OUT_FILE"
	sudo sysctl -a > $CONFIG_OUT_FILE
}

# backup current sysctl config files
function backup_sysctl_config_files {
	ensure_out_file_dir "$FILES_OUT_FILE"
	echo "{}" > $FILES_OUT_FILE
	for i in $(sudo ls /etc/sysctl.d); do
		current_content="$(sudo jq -Rsa '.' /etc/sysctl.d/$i)"
		(($VERBOSITY > 3)) && echo "current_content - $current_content"
		json_content='{"'$i'":'$current_content'}'
		(($VERBOSITY > 3)) && echo "json_content - $json_content"
		new_content=$(jq '. += '"$json_content"'' "$FILES_OUT_FILE")
		echo "$new_content" > $FILES_OUT_FILE
	done
}

# create backup manifest
function backup_manifest {
	ensure_out_file_dir "$MANIFEST_OUT_FILE"
	(
		cat <<- EOF
			{
				"files": [
					{"type": "config", "value": "$CONFIG_OUT_FILE"},
					{"type": "files", "value": "$FILES_OUT_FILE"},
					{"type": "manifest", "value": "$MANIFEST_OUT_FILE"}
				],
				"timestamp": "$OUT_FILE_TIMESTAMP"
			}
		EOF
	) | jq . > "$MANIFEST_OUT_FILE"
}

# list backups
function list_backups {
	ensure_out_file_dir "$MANIFEST_OUT_FILE"
	backup_manifests="$(ls -1a "$ORIGINAL_OUT_DIR" | grep "$OUT_FILE_PREFIX-manifest" | sort)"
	for i in $backup_manifests; do
		current_file="${ORIGINAL_OUT_DIR}${i}"
		echo "$(date -d @$(jq -r '.timestamp' "$current_file")) - $current_file"
	done
}

# ensure backup
function ensure_backup {
	if [ "$RESTORE_MANIFEST_FILE" == "latest" ]; then
		RESTORE_MANIFEST_FILE=$(list_backups | tail -n 1 | sed 's#.* - ##g')
		(($VERBOSITY > 0)) && echo "picked $RESTORE_MANIFEST_FILE as the restore manifest file."
	fi
	if [ ! -f "$RESTORE_MANIFEST_FILE" ]; then
		echo "no valid manifest file" >&2
		exit 1
	fi
	if [[ "$RESTORE_MANIFEST_FILE" =~ \.json$ ]] && [ ! $(jq empty "$RESTORE_MANIFEST_FILE" > /dev/null 2>&1; echo $?) -eq 0 ]; then
		echo "bad manifest file selected at $RESTORE_MANIFEST_FILE" >&2
		jq empty "$RESTORE_MANIFEST_FILE"
		exit 1
	fi
}

# get the selected backup from the manifest file
function get_backup_location {
	backup_location_json=$(jq '.files[] | select(.type=="'$1'")' "$RESTORE_MANIFEST_FILE")
	# check if the selected backup is in the manifest
	if [ -z "$backup_location_json" ]; then
		echo ""
	else
		backup_location="$(echo "$backup_location_json" | jq -r '.value')"
		# check if the backup in the manifest exists
		if [ ! -f "$backup_location" ]; then
			echo "backup listed in manifest not found - $backup_location" >&2
			exit 1
		fi
		# if the backup is json, make sure it's valid
		if [[ "$backup_location" =~ \.json$ ]] && [ ! $(jq empty "$backup_location" > /dev/null 2>&1; echo $?) -eq 0 ]; then
			echo "bad json backup file selected at $backup_location" >&2
			jq empty $backup_location
			exit 1
		fi
		# TODO: maybe find a way to validate the config backup
		echo "$backup_location"
	fi
}

function restore_files_backup {
	files_backup_location="$1"
	backup_content="$(jq '.' "$files_backup_location")"
	extra_args=""
	if (($VERBOSITY > 0)); then
		extra_args="-v"
	fi
	{
		# clean the sysctl.d directory
		sudo mv $extra_args -f /etc/sysctl.d/ /etc/sysctl.d.old/
		sudo mkdir -p /etc/sysctl.d/
		# restore the content from the backup
		for i in $(echo "$backup_content" | jq -r '. | keys[]'); do
			(($VERBOSITY > 1)) && echo "restoring $i to /etc/sysctl.d/"
			echo "$backup_content" | jq -r '."'$i'"' | sudo tee -a "/etc/sysctl.d/$i"
		done
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
		echo "error - $ERR" >&2
		exit 1
	}
}

function restore_config_backup {
	config_backup_location="$1"

	# retsore the content
	cat "$config_backup_location" | while read i; do
		stripped_i="$(echo "$i" | sed 's/ //g')"
		(($VERBOSITY > 1)) && echo "sudo sysctl -w $stripped_i"
		sudo sysctl -w $i
	done
}

# restore backup
function restore_backup {
	ensure_backup
	files_backup_location="$(get_backup_location "files")"
	config_backup_location="$(get_backup_location "config")"

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
}

#
# CLI parsing
#
PARAMS=""
while (("$#")); do
	case "$1" in
	# config out file, optional argument
	--config-out-file)
		if [ -n "$2" ] && [ "${2:0:1}" != "-" ]; then
			CONFIG_OUT_FILE=$2
			shift 2
		else
			echo "Error: Argument for $1 is missing" >&2
			help
			exit 1
		fi
		;;
	# files out file, optional argument
	--files-out-file)
		if [ -n "$2" ] && [ "${2:0:1}" != "-" ]; then
			FILES_OUT_FILE=$2
			shift 2
		else
			echo "Error: Argument for $1 is missing" >&2
			help
			exit 1
		fi
		;;
	# files out file, optional argument
	-r | --restore)
		if [ -n "$2" ] && [ "${2:0:1}" != "-" ]; then
			RESTORE_MANIFEST_FILE=$2
			shift 2
		else
			echo "Error: Argument for $1 is missing" >&2
			help
			exit 1
		fi
		;;
	# config out file, optional argument
	-c | --clean)
		SHOULD_CLEAN=true
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

[ $SHOW_HELP == true ] && help && exit 0
[ $SHOULD_LIST == true ] && list_backups && exit 0
[ $SHOULD_CLEAN == true ] && clean_backups && exit 0
[ ! -z "$RESTORE_MANIFEST_FILE" ] && restore_backup && exit 0

backup_sysctl_config
backup_sysctl_config_files
backup_manifest

# [ubuntu@Ubuntu_VM:~]
# Needed for ECK to run correctly without OOM errors
# echo 'vm.max_map_count=524288' | sudo tee -a /etc/sysctl.d/vm-max_map_count.conf
# Alternatively can use (not persistent after restart):
# sudo sysctl -w vm.max_map_count=524288


# Needed by Sonarqube
# echo 'fs.file-max=131072' | sudo tee -a /etc/sysctl.d/fs-file-max.conf
# Alternatively can use (not persistent after restart):  
# sudo sysctl -w fs.file-max=131072

# Also Needed by Sonarqube
# ulimit -n 131072
# ulimit -u 8192

# Load updated configuration
# sudo sysctl --load --system

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
