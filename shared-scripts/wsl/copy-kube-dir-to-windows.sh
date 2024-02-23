#! /usr/bin/env bash

# TODO: this should be abstracted into a generic backup script with this script calling that with windows options

#
# Environment Validation
#
validation="$(environment-validation -c -l "core" 2>&1)"
if [ ! -z "$validation" ]; then
	echo "Validation error:" >&2
	echo "$validation" >&2
	exit 1
fi

#
# global defaults
#
SHOW_HELP=false
BACKUP_DIR_NAME=${BASIC_SETUP_WSL_COPY_KUBE_DIR_TO_WINDOWS_BACKUP_DIR_NAME:-""}
INTERACTIVE=${BASIC_SETUP_WSL_COPY_KUBE_DIR_TO_WINDOWS_INTERACTIVE:-""}
REVERSE_SELECTION=${BASIC_SETUP_WSL_COPY_KUBE_DIR_TO_WINDOWS_REVERSE_SELECTION:-""}
SOURCE_DIR=${BASIC_SETUP_WSL_COPY_KUBE_DIR_TO_WINDOWS_SOURCE_DIR:-""}
TARGET_DIR=${BASIC_SETUP_WSL_COPY_KUBE_DIR_TO_WINDOWS_TARGET_DIR:-""}
WINDOWS_USER_DIR=${BASIC_SETUP_WSL_WINDOWS_USER_DIR:-""}
WINDOWS_USERNAME=${BASIC_SETUP_WSL_COPY_KUBE_DIR_TO_WINDOWS_WINDOWS_USERNAME:-""}
VERBOSITY=${BASIC_SETUP_VERBOSITY:--1}

#
# load environment variables
#
. basic-setup-set-env

#
# computed values (often can't be alphabetical)
#
if (( $VERBOSITY == -1 )); then
	VERBOSITY=${BASIC_SETUP_VERBOSITY:-0}
fi
if [ -z $BACKUP_DIR_NAME ]; then
	BACKUP_DIR_NAME=${BASIC_SETUP_WSL_COPY_KUBE_DIR_TO_WINDOWS_BACKUP_DIR_NAME:-".kube.bak"}
fi
if [ -z $INTERACTIVE ]; then
	INTERACTIVE=${BASIC_SETUP_WSL_COPY_KUBE_DIR_TO_WINDOWS_INTERACTIVE:-false}
fi
if [ -z $REVERSE_SELECTION ]; then
	REVERSE_SELECTION=${BASIC_SETUP_WSL_COPY_KUBE_DIR_TO_WINDOWS_REVERSE_SELECTION:-false}
fi
if [ -z $SOURCE_DIR ]; then
	SOURCE_DIR=${BASIC_SETUP_WSL_COPY_KUBE_DIR_TO_WINDOWS_SOURCE_DIR:-"${HOME}"}
fi
if [ -z $WINDOWS_USER_DIR ]; then
	WINDOWS_USER_DIR=${BASIC_SETUP_WSL_WINDOWS_USER_DIR:-"/mnt/c/Users"}
fi
if [ -z $WINDOWS_USERNAME ]; then
	WINDOWS_USERNAME=${BASIC_SETUP_WSL_COPY_KUBE_DIR_TO_WINDOWS_WINDOWS_USERNAME:-"$(whoami)"}
fi
if [ -z $TARGET_DIR ]; then
	TARGET_DIR=${BASIC_SETUP_WSL_COPY_KUBE_DIR_TO_WINDOWS_TARGET_DIR:-"$WINDOWS_USER_DIR/$WINDOWS_USERNAME"}
fi

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
		description: copy the ~/.kube directory to Windows, will backup the existing directory if it exists
		----------
		-b|--bakup-dir         - (optional, current: $BAKUP_DIR) The name of the directory to bakup the kube directory to (same parent), also set with \`BASIC_SETUP_WSL_COPY_KUBE_DIR_TO_WINDOWS_BAKUP_DIR\`.
		-h|--help              - (flag, current: $SHOW_HELP) Print this help message and exit.
		-i|--interactive       - (flag, current: $INTERACTIVE) Prompt before overwriting backup files, also set with \`BASIC_SETUP_WSL_COPY_KUBE_DIR_TO_WINDOWS_INTERACTIVE\`.
		-r|--reverse-selection - (flag, current: $REVERSE_SELECTION) Reverse the selection of the source and target directories, also set with \`BASIC_SETUP_WSL_COPY_KUBE_DIR_TO_WINDOWS_REVERSE_SELECTION\`.
		-s|--source-dir        - (optional, current: $SOURCE_DIR) The source directory to copy the kube directory from, also set with \`BASIC_SETUP_WSL_COPY_KUBE_DIR_TO_WINDOWS_SOURCE_DIR\`.
		-t|--target-dir        - (optional, current: $TARGET_DIR) The target directory to copy the kube directory to, also set with \`BASIC_SETUP_WSL_COPY_KUBE_DIR_TO_WINDOWS_TARGET_DIR\`.
		-v|--verbose           - (multi-flag, current: $VERBOSITY) Increase the verbosity by 1, also set with \`BASIC_SETUP_VERBOSITY\`.
		-w|--windows-username  - (optional, current: $WINDOWS_USERNAME) The Windows username to copy the kube directory to, also set with \`BASIC_SETUP_WSL_COPY_KUBE_DIR_TO_WINDOWS_WINDOWS_USERNAME\`.
		----------
		examples:
		copy kube dir to Windows - $command_for_help
		copy kube dir to WSL     - $command_for_help -r
		----------
	EOF
}

#
# CLI parsing
#
PARAMS=""
while (("$#")); do
	case "$1" in
	# backup directory name
	-b | --backup-dir)
		if [ -n "$2" ] && [ ${2:0:1} != "-" ]; then
			BACKUP_DIR_NAME=$2
			shift 2
		else
			echo "Error: Argument for $1 is missing" >&2
			help
			exit 1
		fi
		;;
	# help flag
	-h | --help)
		SHOW_HELP=true
		shift
		;;
	# interactive flag
	-i | --interactive)
		INTERACTIVE=true
		shift
		;;
	# reverse selection flag
	-r | --reverse-selection)
		REVERSE_SELECTION=true
		shift
		;;
	# source directory
	-s | --source-dir)
		if [ -n "$2" ] && [ ${2:0:1} != "-" ]; then
			SOURCE_DIR=$2
			shift 2
		else
			echo "Error: Argument for $1 is missing" >&2
			help
			exit 1
		fi
		;;
	# target directory
	-t | --target-dir)
		if [ -n "$2" ] && [ ${2:0:1} != "-" ]; then
			TARGET_DIR=$2
			shift 2
		else
			echo "Error: Argument for $1 is missing" >&2
			help
			exit 1
		fi
		;;
	# verbosity multi-flag
	-v | --verbose)
		((VERBOSITY+=1))
		shift
		;;
	# windows username
	-w | --windows-username)
		if [ -n "$2" ] && [ ${2:0:1} != "-" ]; then
			WINDOWS_USERNAME=$2
			shift 2
		else
			echo "Error: Argument for $1 is missing" >&2
			help
			exit 1
		fi
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

# error if not on WSL
if [ "$(wsl-is-on-wsl)" != "true" ]; then
	echo "Error: This system doesn't seem to be on WSL" >&2
	exit 1
fi

if [ -z "$WINDOWS_USERNAME" ]; then
	echo "Error: Argument for -w|--windows-username is missing" >&2
	help
	exit 1
fi

# error if source directory is missing
if [ -z "$SOURCE_DIR" ]; then
	echo "Error: Argument for -s|--source-dir is missing" >&2
	help
	exit 1
fi

# error if source directory doesn't exist
if [ ! -d "$SOURCE_DIR" ]; then
	echo "Error: Source directory \"$SOURCE_DIR\" doesn't exist" >&2
	exit 1
fi

# error if target directory is missing
if [ -z "$TARGET_DIR" ]; then
	echo "Error: Argument for -t|--target-dir is missing" >&2
	help
	exit 1
fi

# error if target directory doesn't exist
if [ ! -d "$TARGET_DIR" ]; then
	echo "Error: Target directory \"$TARGET_DIR\" doesn't exist" >&2
	exit 1
fi

# error if backup directory name is missing
if [ -z "$BACKUP_DIR_NAME" ]; then
	echo "Error: Argument for -b|--backup-dir is missing" >&2
	help
	exit 1
fi

# reverse the selection of the source and target directories
if [ "$REVERSE_SELECTION" == "true" ]; then
	TEMP_DIR="$TARGET_DIR"
	TARGET_DIR="$SOURCE_DIR"
	SOURCE_DIR="$TEMP_DIR"
fi

# set the backup directory
BACKUP_DIR="$TARGET_DIR/$BACKUP_DIR_NAME"

# error or prompt if backup directory exists
if [ -d "$BACKUP_DIR" ]; then
	if [ "$INTERACTIVE" == "true" ]; then
		echo "\"$BACKUP_DIR\" exists, would you like to remove it? [y/n]: " && read
		echo
		if [[ "$REPLY" =~ ^[Yy]$ ]]; then
			rm -rf "$BACKUP_DIR"
		else
			echo "Didn't remove \"$BACKUP_DIR\", exiting..." >&2
			exit 1
		fi
	else
		echo "\"$BACKUP_DIR\" exists, exiting..." >&2
		exit 1
	fi
fi

# backup the existing kube directory
if [ -d "$TARGET_DIR/.kube" ]; then
	mv "$TARGET_DIR/.kube" "$BACKUP_DIR"
fi

# copy the kube directory to Windows
cp -r "$SOURCE_DIR/.kube/" "$TARGET_DIR/"
