#! /usr/bin/env bash

#
# global defaults
#
LOG_DIR="/tmp/k3d-dev-logs"
SHOW_HELP=false
USE_LOCAL_LOG=false
USE_REGISTRY_YAML=true
VERBOSITY=0

REGISTRY_URL="registry1.dso.mil"
USE_EXISTING_SECRET=false
REGISTRY_USERNAME=""
REGISTRY_PASSWORD=""
WAIT_TIMEOUT=120

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

# script help message
function help {
	command_for_help="$(basename "$0")"
	cat <<- EOF
		----------
		usage: $command_for_help <arguments>
		----------
		description: runs the k3d-dev wrapper, then runs the install-flux wrapper
		----------
		wrapper flags:
		-d|--k3d-d   - see below
		-h|--help    - (flag, default: false) Print this help message and exit.
		-l|--log     - (flag, default: false) Dump the log for k3d-dev to./$LOG_FILE_NAME.
		-m|--manual  - (flag, default: true) Use prompting or other args to auth, instead of the default of using overrides/registry-values.yaml for flux
		-v|--verbose - (multi-flag, default: 0) Increase the verbosity by 1.
		flux script flags (all flags below are passed to bb-install_flux.sh):
		--flux-r - (optional, default: registry1.dso.mil) registry url to use for flux installation
		--flux-s - (optional) use existing private-registry secret 
		--flux-u - (required) registry username to use for flux installation
		--flux-p - (optional, prompted if no existing secret) registry password to use for flux installation
		--flux-w - (optional, default: 120) how long to wait; in seconds, for each key flux resource component
		k3d script flags (all flags below are passed to bb-k3d-dev.sh):
		--k3d-b    - use BIG M5 instance. Default is m5a.4xlarge
		--k3d-p    - use private IP for security group and k3d cluster
		--k3d-m    - create k3d cluster with metalLB
		--k3d-a    - attach secondary Public IP (overrides -p and -m flags)
		-d|--k3d-d - destroy related AWS resources
		--k3d-w    - install the weave CNI instead of the default flannel CNI
		----------
		examples:
		build a dev env  - $command_for_help
		destoy a dev env - $command_for_help -d
		----------
	EOF
}

# Builds the args to pass to bb-install_flux.sh
build-k3d-args() {
	local args=""
	if [ "$SHOW_HELP" == true ]; then
		local args="$args -h"
	fi
	if [ "$USE_BIG_M5" == true ]; then
		local args="$args -b"
	fi
	if [ "$USE_LOCAL_LOG" == true ]; then
		local args="$args -l"
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

# Builds the args to pass to bb-install_flux.sh
build-flux-args() {
	local args=""
	if [ "$SHOW_HELP" == true ]; then
		local args="$args -h"
	fi
	if [ "$USE_EXISTING_SECRET" == true ]; then
		local args="$args -s"
	fi
	if [ -n "$WAIT_TIMEOUT" ]; then
		local args="$args -w $WAIT_TIMEOUT"
	fi
	if [ "$USE_REGISTRY_YAML" == false ]; then
		local args="$args -m"
	fi
	if [ -n "$REGISTRY_URL" ]; then
		local args="$args -r $REGISTRY_URL"
	fi
	if [ -n "$REGISTRY_USERNAME" ]; then
		local args="$args -u $REGISTRY_USERNAME"
	fi
	if [ -n "$REGISTRY_PASSWORD" ]; then
		local args="$args -p $REGISTRY_PASSWORD"
	fi
	echo "$args"
}

#
# CLI parsing
#
PARAMS=""
while (("$#")); do
	case "$1" in
	# attach secondary ip flag
	--k3d-a)
		ATTACH_SECONDARY_PUBLIC_IP=true
		shift
		;;
	# big flag
	--k3d-b)
		USE_BIG_M5=true
		shift
		;;
	# destroy flag
	--k3d-d)
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
	--k3d-m)
		USE_METALLB=true
		shift
		;;
	# manual auth flag
	-m | --manual)
		USE_REGISTRY_YAML=false
		shift
		;;
	# private ip flag
	--k3d-p)
		USE_PRIVATE_IP=true
		shift
		;;
	# registry password, optional argument
	--flux-p)
		if [ -n "$2" ] && [ "${2:0:1}" != "-" ]; then
			REGISTRY_PASSWORD=$2
			shift 2
		else
			echo "Error: Argument for $1 is missing" >&2
			help
			exit 1
		fi
		;;
	# registry, optional argument
	--flux-r)
		if [ -n "$2" ] && [ "${2:0:1}" != "-" ]; then
			REGISTRY_URL=$2
			shift 2
		else
			echo "Error: Argument for $1 is missing" >&2
			help
			exit 1
		fi
		;;
	# manual auth flag
	--flux-s)
		USE_EXISTING_SECRET=true
		shift
		;;
	# registry username, optional argument
	--flux-u)
		if [ -n "$2" ] && [ "${2:0:1}" != "-" ]; then
			REGISTRY_USERNAME=$2
			shift 2
		else
			echo "Error: Argument for $1 is missing" >&2
			help
			exit 1
		fi
		;;
	# weave flag
	--k3d-w)
		USE_WEAVE=true
		shift
		;;
	# wait timeout, optional argument
	--flux-w)
		if [ -n "$2" ] && [ "${2:0:1}" != "-" ]; then
			WAIT_TIMEOUT=$2
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
[ $SHOW_HELP == true ] && help && printf "\n\n" && (big-bang-k3d-dev-wrapper -h || return 0) && printf "\n\n" && (big-bang-install-flux-wrapper -h || return 0) && exit 0

sudo cat /dev/null # prompt for sudo password now

k3d_args="$(build-k3d-args)"
flux_args="$(build-flux-args)"

big-bang-k3d-dev-wrapper $k3d_args
if [ $DESTROY == true ]; then
	(($VERBOSITY > 0)) && echo "message: Destroying k3d-dev cluster, so not installing flux." >&2
	exit 0
fi
big-bang-install-flux-wrapper $flux_args
