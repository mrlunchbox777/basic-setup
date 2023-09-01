#! /usr/bin/env bash

#
# global defaults
#
LOG_DIR="/tmp/k3d-dev-logs"
DEV_ENV_NAMESPACE="bigbang"
EXCLUDE_DEFAULT_YAML=false
INSTALL_BIGBANG=false
INSTALL_COMMAND=""
OVERRIDE_FILES=()
YAML_FILES=()
SHOW_HELP=false
SKIP_FLUX=false
SKIP_INSTALL=false
SKIP_K3D=false
SKIP_SECRET=false
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
		description: runs big-bang-k3d-dev-wrapper, then runs the big-bang-install-flux-wrapper, then creates the namespace and secret, then runs the big-bang-install-helm
		----------
		dev-env flags:
		-h|--help         - (flag, default: false) Print this help message and exit.
		-i|--skip-install - (flag, default: false) Skips helm-install.
		-k|--skip-k3d     - (flag, default: false) Skips the k3d.
		-n|--namespace    - (flag, default: "bigbang") The namespace to use for the dev env, required if -s is not set.
		-s|--skip-secret  - (flag, default: true) If the secret should be created.
		-u|--skip-flux    - (flag, default: false) Skips flux commands.
		-v|--verbose      - (multi-flag, default: 0) Increase the verbosity by 1.

		k3d script flags (all flags below are passed to big-bang-k3d-dev-wrapper):
		-d|--k3d-d   - destroy related AWS resources
		-h|--help    - (flag, default: false) Print this help message and exit.
		-l|--log     - (flag, default: false) Dump the log for k3d-dev to./ instead of /tmp/k3d-dev-logs/.
		-v|--verbose - (multi-flag, default: 0) Increase the verbosity by 1.
		--k3d-b      - use BIG M5 instance. Default is m5a.4xlarge
		--k3d-p      - use private IP for security group and k3d cluster
		--k3d-m      - create k3d cluster with metalLB
		--k3d-a      - attach secondary Public IP (overrides -p and -m flags)
		--k3d-w      - install the weave CNI instead of the default flannel CNI

		flux script flags (all flags below are passed to big-bang-install-flux-wrapper):
		-h|--help    - (flag, default: false) Print this help message and exit.
		-m|--manual  - (flag, default: true) Use prompting or other args to auth, instead of the default of using overrides/registry-values.yaml for flux
		-v|--verbose - (multi-flag, default: 0) Increase the verbosity by 1.
		--flux-r     - (optional, default: registry1.dso.mil) registry url to use for flux installation
		--flux-s     - (optional) use existing private-registry secret 
		--flux-u     - (required) registry username to use for flux installation
		--flux-p     - (optional, prompted if no existing secret) registry password to use for flux installation
		--flux-w     - (optional, default: 120) how long to wait; in seconds, for each key flux resource component

		helm install script flags (all flags below are passed to big-bang-helm-install):
		-b|--install-bigbang      - (flag, default: false) Install bigbang, mutually exclusive with -c, one is required.
		-c|--install-command      - (flag, default: empty string) name of install script in the override dir, mutually exclusive with -b, one is required.
		-e|--exclude-default-yaml - (flag, default: false) Don't include chart/values.yaml and overrides/registry-values.yaml.
		-f|--yaml-file            - (multi-option, default: empty array) Any number of yaml files in the override dir to include with -f on the install command, e.g. ~/extra-value.yaml.
		-h|--help                 - (flag, default: false) Print this help message and exit.
		-o|--override-files       - (multi-option, default: empty array) Any number of files in the override dir to include with -f on the install command, e.g. registry-values.yaml.
		-v|--verbose              - (multi-flag, default: 0) Increase the verbosity by 1.
		----------
		examples:
		build a dev env  - $command_for_help -b
		destoy a dev env - $command_for_help -d
		----------
	EOF
}

# Builds the args to pass to big-bang-k3d-dev-wrapper.
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
	for i in $(seq 1 $VERBOSITY); do
		local args="$args -v"
	done
	echo "$args"
}

# Builds the args to pass to big-bang-install-flux-wrapper.
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
	for i in $(seq 1 $VERBOSITY); do
		local args="$args -v"
	done
	echo "$args"
}

# Builds the args to pass to big-bang-helm-install.
build-helm-install-args() {
	local args=""
	if [ "$SHOW_HELP" == true ]; then
		local args="$args -h"
	fi
	if [ "$INSTALL_BIGBANG" == true ]; then
		local args="$args -b"
	fi
	if [ -n "$INSTALL_COMMAN" ]; then
		local args="$args -c \"$INSTALL_COMMAND\""
	fi
	if [ "$EXCLUDE_DEFAULT_YAML" == true ]; then
		local args="$args -e"
	fi
	for yaml_file in "${YAML_FILES[@]}"; do
		local args="$args -f \"$yaml_file\""
	done
	for override_file in "${OVERRIDE_FILES[@]}"; do
		local args="$args -o \"$override_file\""
	done
	for i in $(seq 1 $VERBOSITY); do
		local args="$args -v"
	done
	echo "$args"
}

# Creates the namespace
create-namespace() {
	kubectl create namespace "$DEV_ENV_NAMESPACE" --dry-run=client -o yaml | kubectl apply -f -
}

# Creates the registry secret
create-registry-secret() {
	if [ -z "$DEV_ENV_NAMESPACE" ]; then
		echo "Error: DEV_ENV_NAMESPACE is not set and is required to set the secret" >&2
		exit 1
	fi
	if [ "$USE_REGISTRY_YAML" == true ]; then
		. big-bang-export-registry-credentials
	fi
	if [ -z "$REGISTRY_URL" ]; then
		echo "Error: REGISTRY_URL is not set and is required to set the secret" >&2
		exit 1
	fi
	if [ -z "$REGISTRY_USERNAME" ]; then
		echo "Error: REGISTRY_USERNAME is not set and is required to set the secret" >&2
		exit 1
	fi
	if [ -z "$REGISTRY_PASSWORD" ]; then
		echo "Error: REGISTRY_PASSWORD is not set and is required to set the secret" >&2
		exit 1
	fi
	kubectl create secret docker-registry private-registry --docker-server="$REGISTRY_URL" --docker-username="$REGISTRY_USERNAME" --docker-password="$REGISTRY_PASSWORD" -n "$DEV_ENV_NAMESPACE" --dry-run=client -o yaml | kubectl apply -f -
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
	# big bang flag
	-b | --install-bigbang)
		INSTALL_BIGBANG=true
		shift
		;;
	# install command flag
	-c | --install-command)
		if [ -n "$2" ] && [ "${2:0:1}" != "-" ]; then
			INSTALL_COMMAND="$2"
			shift 2
		else
			echo "Error: Argument for $1 is missing" >&2
			help
			exit 1
		fi
		;;
	# destroy flag
	-d | --k3d-d)
		DESTROY=true
		shift
		;;
	# exclude default yaml flag
	-e | --exclude-default-yaml)
		EXCLUDE_DEFAULT_YAML=true
		shift
		;;
	# yaml files, multi optional argument
	-f | --yaml-file)
		if [ -n "$2" ] && [ "${2:0:1}" != "-" ]; then
			YAML_FILES+=("$2")
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
	# skip install flag
	-i | --skip-install)
		SKIP_INSTALL=true
		shift
		;;
	-k | --skip-k3d)
		SKIP_K3d=true
		shift
		;;
	# use local log flag
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
	# namespace optional argument
	-n | --namespace)
		if [ -n "$2" ] && [ "${2:0:1}" != "-" ]; then
			DEV_ENV_NAMESPACE=$2
			shift 2
		else
			echo "Error: Argument for $1 is missing" >&2
			help
			exit 1
		fi
		;;
	# override files, multi optional argument
	-o | --override-files)
		if [ -n "$2" ] && [ "${2:0:1}" != "-" ]; then
			OVERRIDE_FILES+=("$2")
			shift 2
		else
			echo "Error: Argument for $1 is missing" >&2
			help
			exit 1
		fi
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
	# skip secret
	-s | --skip-secret)
		SKIP_INSTALL=true
		shift
		;;
	# manual auth flag
	--flux-s)
		USE_EXISTING_SECRET=true
		shift
		;;
	# skip flux flag
	-u | --skip-flux)
		SKIP_FLUX=true
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
[ $SHOW_HELP == true ] && help && printf "\n\n -- running big-bang-k3d-dev-wrapper -h --\n\n" && (big-bang-k3d-dev-wrapper -h || return 0) && printf "\n\n -- running big-bang-install-flux-wrapper -h --\n\n" && (big-bang-install-flux-wrapper -h || return 0) && printf "\n\n -- running big-bang-helm-install -h --\n\n" && (big-bang-helm-install -h || return 0) && exit 0

sudo cat /dev/null # prompt for sudo password now

k3d_args="$(build-k3d-args)"
flux_args="$(build-flux-args)"
helm_install_args="$(build-helm-install-args)"

if [ "$SKIP_K3D" == false ]; then
	big-bang-k3d-dev-wrapper $k3d_args
	if [ $DESTROY == true ]; then
		(($VERBOSITY > 0)) && echo "message: Destroying k3d-dev cluster, exiting." >&2
		exit 0
	fi
fi

if [ $SKIP_FLUX == false ]; then
	big-bang-install-flux-wrapper $flux_args
fi

if [ -n "$DEV_ENV_NAMESPACE" ]; then
	create-namespace
fi

if [ $SKIP_SECRET == false ]; then
	create-registry-secret
fi

if [ "$SKIP_INSTALL" == false ]; then
	big-bang-helm-install $helm_install_args
fi
