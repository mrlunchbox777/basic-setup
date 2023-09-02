#! /usr/bin/env bash

#
# global defaults
#
LOG_DIR="/tmp/k3d-dev-logs"
SHOW_HELP=false
USE_LOCAL_LOG=false
VERBOSITY=0
USE_BIG_M5=false
USE_PRIVATE_IP=false
USE_METALLB=false
ATTACH_SECONDARY_PUBLIC_IP=false
DESTROY=false
USE_WEAVE=false

#
# computed values (often can't be alphabetical)
#
DATE_TO_USE="$(date +%s)"
LOG_FILE_NAME="k3d-dev-$DATE_TO_USE.log"
LOG_FILE=""

#
# helper functions
#

# TODO: add a thing to clean up old kubeconfigs

# script help message
function help {
	command_for_help="$(basename "$0")"
	cat <<- EOF
		----------
		usage: $command_for_help <arguments>
		----------
		description: runs k3d-dev.sh directly from the repo
		----------
		wrapper flags:
		-h|--help    - (flag, default: false) Print this help message and exit.
		-l|--log     - (flag, default: false) Dump the log for k3d-dev to./$LOG_FILE_NAME.
		-v|--verbose - (multi-flag, default: 0) Increase the verbosity by 1.
		script flags (all flags below are passed to bb-k3d-dev.sh):
		-b - use BIG M5 instance. Default is m5a.4xlarge
		-p - use private IP for security group and k3d cluster
		-m - create k3d cluster with metalLB
		-a - attach secondary Public IP (overrides -p and -m flags)
		-d - destroy related AWS resources
		-w - install the weave CNI instead of the default flannel CNI
		-h - output help
		----------
		examples:
		create dev environment      - $command_for_help
		create big dev environment  - $command_for_help -b
		cleanup dev environment     - $command_for_help -d
		----------
	EOF
}

# Builds the args to pass to bb-install_flux.sh
build-args() {
	local args=""
	if [ "$SHOW_HELP" == true ]; then
		local args="$args -h"
	fi
	if [ "$USE_BIG_M5" == true ]; then
		local args="$args -b"
	fi
	if [ "$USE_PRIVATE_IP" == true ]; then
		local args="$args -p"
	fi
	if [ "$USE_METALLB" == true ]; then
		local args="$args -m"
	fi
	if [ "$ATTACH_SECONDARY_PUBLIC_IP" == true ]; then
		local args="$args -a"
	fi
	if [ "$DESTROY" == true ]; then
		local args="$args -d"
	fi
	if [ "$USE_WEAVE" == true ]; then
		local args="$args -w"
	fi
	echo "$args"
}

# Runs the bb-k3d-dev.sh script and logs the output
run-k3d-dev() {
	args="$(build-args)"
	(($VERBOSITY > 0)) && echo "args: $args"
	command="$(readlink "$(command -v bb-k3d-dev.sh)")"
	if [ -z "$command" ]; then
		echo "Error: bb-k3d-dev.sh not found, please run big-bang-relink-scripts" >&2
		help
		exit 1
	fi
	$command $args 2>&1 | tee -a "$LOG_FILE"
}

# do parsing on the log file to get the hosts and kubectl changes
update-hosts-and-kubectl() {
	(($VERBOSITY > 0)) && echo "Updating /etc/hosts and ~/.kube/config"
	new_hosts_file_line="$(grep \.bigbang\.dev "$LOG_FILE")"
	if [ -z "$new_hosts_file_line" ]; then
		echo "Error: no hosts file line found in $LOG_FILE" >&2
		exit 1
	fi
	new_kubectl_line="$(grep '\s*export KUBECONFIG=' "$LOG_FILE" | xargs)"
	if [ -z "$new_kubectl_line" ]; then
		echo "Error: no kubectl line found in $LOG_FILE" >&2
		exit 1
	fi
	new_kubectl_file="$(echo "$new_kubectl_line" | sed 's/.*export KUBECONFIG=//g' | xargs)"
	if [ -z "$new_kubectl_file" ]; then
		echo "Error: no kubectl file found in $LOG_FILE" >&2
		exit 1
	fi
	new_kubectl_file="$(echo "$new_kubectl_file" | sed 's|~|'$HOME'|g')"
	if [ ! -f "$new_kubectl_file" ]; then
		echo "Error: kubectl file not found: $new_kubectl_file" >&2
		exit 1
	fi

	(($VERBOSITY > 0)) && echo "new_hosts_file_line: $new_hosts_file_line"
	(($VERBOSITY > 0)) && echo "new_kubectl_file: $new_kubectl_file"
	sudo sed -i '/.*\.bigbang\.dev.*/d' /etc/hosts # remove old entries
	echo "$new_hosts_file_line" | sudo tee -a /etc/hosts >/dev/null # add new entries
	mv ~/.kube/config ~/.kube/config-$DATE_TO_USE.bak # backup old config
	cp $new_kubectl_file ~/.kube/config # copy new config
}

#
# CLI parsing
#
PARAMS=""
while (("$#")); do
	case "$1" in
	# attach secondary ip flag
	-a)
		ATTACH_SECONDARY_PUBLIC_IP=true
		shift
		;;
	# big flag
	-b)
		USE_BIG_M5=true
		shift
		;;
	# destroy flag
	-d)
		DESTROY=true
		shift
		;;
	# help flag
	-h | --help)
		SHOW_HELP=true
		shift
		;;
	# help flag
	-l | --log)
		USE_LOCAL_LOG=true
		shift
		;;
	# metal lb flag
	-m)
		USE_METALLB=true
		shift
		;;
	# private ip flag
	-p)
		USE_PRIVATE_IP=true
		shift
		;;
	# weave flag
	-w)
		USE_WEAVE=true
		shift
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
[ $SHOW_HELP == true ] && help # don't exit so we get the k3d-dev help as well

sudo cat /dev/null # prompt for sudo password now

# Prep the log file
if [ "$USE_LOCAL_LOG" == true ]; then
	LOG_DIR="."
fi
mkdir -p "$LOG_DIR"
LOG_FILE="$LOG_DIR/$LOG_FILE_NAME"
(($VERBOSITY > 0)) && echo "log_file: $LOG_FILE"

# Run the script
run-k3d-dev

# exit if we are destroying the dev environment
if [ $SHOW_HELP == true ]; then
	(($VERBOSITY > 0)) && echo "Showing help, no changes to /etc/hosts or ~/.kube/config will be made"
	exit 0
fi

# Validate the log file
if [ ! -f "$LOG_FILE" ]; then
	echo "Error: log file not found: $LOG_FILE" >&2
	exit 1
fi
if [ ! -s "$LOG_FILE" ]; then
	echo "Error: log file is empty: $LOG_FILE" >&2
	exit 1
fi

# exit if we are destroying the dev environment
if [ $DESTROY == true ]; then
	(($VERBOSITY > 0)) && echo "Destroying dev environment, no changes to /etc/hosts or ~/.kube/config will be made"
	exit 0
fi

# Update the hosts file and kubectl config
update-hosts-and-kubectl
