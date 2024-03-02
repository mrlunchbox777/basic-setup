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

#
# global defaults
#
DEV_ENV_NAMESPACE=${BASIC_SETUP_BIG_BANG_DEV_ENV_NAMESPACE:-""}
SHOW_FULL_HELP=${BASIC_SETUP_BIG_BANG_DEV_ENV_SHOW_FULL_HELP:-""}
SHOW_HELP=false
SKIP_FLUX=${BASIC_SETUP_BIG_BANG_DEV_ENV_SKIP_FLUX:-""}
SKIP_INSTALL=${BASIC_SETUP_BIG_BANG_DEV_ENV_SKIP_INSTALL:-""}
SKIP_K3D=${BASIC_SETUP_BIG_BANG_DEV_ENV_SKIP_K3D:-""}
SKIP_SECRET=${BASIC_SETUP_BIG_BANG_DEV_ENV_SKIP_SECRET:-""}
VERBOSITY=${BASIC_SETUP_VERBOSITY:--1}

# k3d-dev defaults
ATTACH_SECONDARY_PUBLIC_IP=""
DESTROY=${BASIC_SETUP_BIG_BANG_K3D_DEV_WRAPPER_DESTROY:-""}
USE_BIG_M5=""
USE_LOCAL_LOG=${BASIC_SETUP_BIG_BANG_K3D_DEV_WRAPPER_USE_LOCAL_LOG:-""}
USE_METALLB=""
USE_PRIVATE_IP=""
USE_WEAVE=""

# flux defaults
REGISTRY_URL=""
REGISTRY_PASSWORD=""
REGISTRY_USERNAME=""
USE_EXISTING_SECRET=""
USE_REGISTRY_YAML=${BASIC_SETUP_BIG_BANG_INSTALL_FLUX_WRAPPER_USE_REGISTRY_YAML:-""}
WAIT_TIMEOUT=""

# helm install defaults
EXCLUDE_DEFAULT_YAML=${BASIC_SETUP_BIG_BANG_HELM_INSTALL_EXCLUDE_DEFAULT_YAML:-""}
INSTALL_COMMAND=""
OVERRIDE_FILES=()
YAML_FILES=()

#
# load environment variables
#
. basic-setup-set-env

#
# computed values (often can't be alphabetical)
#
if [ -z "$DEV_ENV_NAMESPACE" ]; then
	DEV_ENV_NAMESPACE=${BASIC_SETUP_BIG_BANG_DEV_ENV_NAMESPACE:-"bigbang"}
fi
if [ -z "$SHOW_FULL_HELP" ]; then
	SHOW_FULL_HELP=${BASIC_SETUP_BIG_BANG_DEV_ENV_SHOW_FULL_HELP:-false}
fi
if [ -z "$SKIP_FLUX" ]; then
	SKIP_FLUX=${BASIC_SETUP_BIG_BANG_DEV_ENV_SKIP_FLUX:-false}
fi
if [ -z "$SKIP_INSTALL" ]; then
	SKIP_INSTALL=${BASIC_SETUP_BIG_BANG_DEV_ENV_SKIP_INSTALL:-false}
fi
if [ -z "$SKIP_K3D" ]; then
	SKIP_K3D=${BASIC_SETUP_BIG_BANG_DEV_ENV_SKIP_K3D:-false}
fi
if [ -z "$SKIP_SECRET" ]; then
	SKIP_SECRET=${BASIC_SETUP_DEV_ENV_SKIP_SECRET:-false}
fi
if (( $VERBOSITY == -1 )); then
	VERBOSITY=${BASIC_SETUP_VERBOSITY:-0}
fi

# k3d computed values
if [ -z "$DESTROY" ]; then
	DESTROY=${BASIC_SETUP_BIG_BANG_K3D_DEV_WRAPPER_DESTROY:-false}
fi
if [ -z "$USE_LOCAL_LOG" ]; then
	USE_LOCAL_LOG=${BASIC_SETUP_BIG_BANG_K3D_DEV_WRAPPER_USE_LOCAL_LOG:-false}
fi

# flux computed values
if [ -z "$USE_REGISTRY_YAML" ]; then
	USE_REGISTRY_YAML=${BASIC_SETUP_BIG_BANG_INSTALL_FLUX_WRAPPER_USE_REGISTRY_YAML:-true}
fi

# helm install computed values
if [ -z "$EXCLUDE_DEFAULT_YAML" ]; then
	EXCLUDE_DEFAULT_YAML=${BAISC_SETUP_BIG_BANG_HELM_INSTALL_EXCLUDE_DEFAULT_YAML:-false}
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
		description: runs big-bang-k3d-dev-wrapper, then runs the big-bang-install-flux-wrapper, then creates the namespace and secret, then runs the big-bang-install-helm
		----------
		dev-env flags:
		-h|--help         - (flag, current: $SHOW_HELP) Print this help message and exit.
		-i|--skip-install - (flag, current: $SKIP_INSTALL) Skips helm-install.
		-k|--skip-k3d     - (flag, current: $SKIP_K3D) Skips the k3d.
		-n|--namespace    - (optional, current: "$DEV_ENV_NAMESPACE") The namespace to use for the dev env, required if -s is not set.
		-s|--skip-secret  - (flag, current: $SKIP_SECRET) If the secret should be created.
		-u|--skip-flux    - (flag, current: $SKIP_FLUX) Skips flux commands.
		-v|--verbose      - (multi-flag, current: $VERBOSITY) Increase the verbosity by 1, also set with \`BASIC_SETUP_VERBOSITY\`.
		--full-help       - (flag, current: $SHOW_FULL_HELP) Print the help message for all the scripts used in this script, overrides the subscripts environment variables, also set with \`BASIC_SETUP_BIG_BANG_DEV_ENV_SHOW_FULL_HELP\`.

		The following script parameters may have defaults set in those scripts, see the help for those scripts for more info (pass --full-help).

		k3d script flags (all flags below are passed to big-bang-k3d-dev-wrapper):
		-d|--k3d-d   - -d, current: "$DESTROY", also set with \`BASIC_SETUP_BIG_BANG_K3D_DEV_WRAPPER_DESTROY\`
		-h|--help    - -h, current: "$SHOW_HELP"
		-l|--log     - -l, current: "$USE_LOCAL_LOG", also set with \`BASIC_SETUP_BIG_BANG_K3D_DEV_WRAPPER_USE_LOCAL_LOG\`
		-v|--verbose - -v, current: $VERBOSITY, also set with \`BASIC_SETUP_VERBOSITY\`
		--k3d-b      - -b, current: "$USE_BIG_M5", also set with \`BASIC_SETUP_BIG_BANG_K3D_DEV_WRAPPER_USE_BIG_M5\`
		--k3d-p      - -p, current: "$USE_PRIVATE_IP", also set with \`BASIC_SETUP_BIG_BANG_K3D_DEV_WRAPPER_USE_PRIVATE_IP\`
		--k3d-m      - -m, current: "$USE_METALLB", also set with \`BASIC_SETUP_BIG_BANG_K3D_DEV_WRAPPER_USE_METALLB\`
		--k3d-a      - -a, current: "$ATTACH_SECONDARY_PUBLIC_IP", also set with \`BASIC_SETUP_BIG_BANG_K3D_DEV_WRAPPER_ATTACH_SECONDARY_PUBLIC_IP\`
		--k3d-w      - -w, current: "$USE_WEAVE", also set with \`BASIC_SETUP_BIG_BANG_K3D_DEV_WRAPPER_USE_WEAVE\`
		--full-help  - --full-help, current: "$SHOW_FULL_HELP", also set with \`BASIC_SETUP_BIG_BANG_K3D_DEV_WRAPPER_SHOW_FULL_HELP\`

		flux script flags (all flags below are passed to big-bang-install-flux-wrapper):
		-h|--help    - -h|--help, current: "$SHOW_HELP", also set with \`BASIC_SETUP_BIG_BANG_INSTALL_FLUX_WRAPPER_SHOW_HELP\`
		-m|--manual  - -m|--manual, current: "$USE_REGISTRY_YAML", also set with \`BASIC_SETUP_BIG_BANG_INSTALL_FLUX_WRAPPER_USE_REGISTRY_YAML\`
		-v|--verbose - -v|--verbose, current: $VERBOSITY, also set with \`BASIC_SETUP_VERBOSITY\`
		--flux-r     - -r|--registry-url, current: "$REGISTRY_URL", also set with \`BASIC_SETUP_BIG_BANG_INSTALL_FLUX_WRAPPER_REGISTRY_URL\`
		--flux-s     - -s|--use-existing-secret, current: "$USE_EXISTING_SECRET", also set with \`BASIC_SETUP_BIG_BANG_INSTALL_FLUX_WRAPPER_USE_EXISTING_SECRET\`
		--flux-u     - -u|--registry-username, current: "$REGISTRY_USERNAME", also set with \`BASIC_SETUP_BIG_BANG_INSTALL_FLUX_WRAPPER_REGISTRY_USERNAME\`
		--flux-p     - -p|--registry-password, current: "$REGISTRY_PASSWORD", also set with \`BASIC_SETUP_BIG_BANG_INSTALL_FLUX_WRAPPER_REGISTRY_PASSWORD\`
		--flux-w     - -w|--wait-timeout, current: $WAIT_TIMEOUT, also set with \`BASIC_SETUP_BIG_BANG_INSTALL_FLUX_WRAPPER_WAIT_TIMEOUT\`
		--full-help  - --full-help, current: "$SHOW_FULL_HELP", also set with \`BASIC_SETUP_BIG_BANG_INSTALL_FLUX_WRAPPER_SHOW_FULL_HELP\`

		helm install script flags (all flags below are passed to big-bang-helm-install):
		-c|--install-command      - -c|--install-command, current: "$INSTALL_COMMAND"
		-e|--exclude-default-yaml - -e|--exclude-default-yaml, current: $EXCLUDE_DEFAULT_YAML, also set with \`BAISC_SETUP_HELM_INSTALL_EXCLUDE_DEFAULT_YAML\`
		-f|--yaml-file            - -f|--yaml-file, current: (${YAML_FILES[@]})
		-h|--help                 - -h|--help, current: "$SHOW_HELP"
		-o|--override-files       - -o|--override-files, current: (${OVERRIDE_FILES[@]})
		-v|--verbose              - -v|--verbose, current: $VERBOSITY, also set with \`BASIC_SETUP_VERBOSITY\`
		----------
		note: the -h for for helm install, flux, and k3d-dev will only show if --full-help is set.
		note: everything under big-bang will be moved to https://repo1.dso.mil/big-bang/product/packages/bbctl eventually
		----------
		examples:
		build a dev env                       - $command_for_help
		destoy a dev env                      - $command_for_help -d
		build a dev env with an override yaml - $command_for_help -o default-disables.yaml
		build a dev env with an external yaml - $command_for_help -f /tmp/foo/bar.yaml
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
	if [ "$SHOW_FULL_HELP" == true ]; then
		local args="$args --full-help"
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
	if [ "$SHOW_FULL_HELP" == true ]; then
		local args="$args --full-help"
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
	if [ -n "$INSTALL_COMMAND" ]; then
		local args="$args -c \"$INSTALL_COMMAND\""
	fi
	if [ "$EXCLUDE_DEFAULT_YAML" == true ]; then
		local args="$args -e"
	fi
	for yaml_file in "${YAML_FILES[@]}"; do
		local args="$args -f $yaml_file"
	done
	for override_file in "${OVERRIDE_FILES[@]}"; do
		local args="$args -o $override_file"
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
	# full help flag
	--full-help)
		SHOW_FULL_HELP=true
		shift
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
	# metal lb flag
	--k3d-m)
		USE_METALLB=true
		shift
		;;
	# private ip flag
	--k3d-p)
		USE_PRIVATE_IP=true
		shift
		;;
	# weave flag
	--k3d-w)
		USE_WEAVE=true
		shift
		;;
	# use local log flag
	-l | --log)
		USE_LOCAL_LOG=true
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
	# skip secret
	-s | --skip-secret)
		SKIP_INSTALL=true
		shift
		;;
	# skip flux flag
	-u | --skip-flux)
		SKIP_FLUX=true
		shift
		;;
	# registry username, optional argument
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
if [ $SHOW_HELP == true ]; then
	help
	if [ "$SHOW_FULL_HELP" == "false" ]; then
		exit 0
	else
		printf "\n\n -- running big-bang-k3d-dev-wrapper -h --\n\n" && (big-bang-k3d-dev-wrapper -h || return 0)
		printf "\n\n -- running big-bang-install-flux-wrapper -h --\n\n" && (big-bang-install-flux-wrapper -h || return 0)
		printf "\n\n -- running big-bang-helm-install -h --\n\n" && (big-bang-helm-install -h || return 0) && exit 0
	fi
fi

sudo cat /dev/null # prompt for sudo password now needed to update /etc/hosts

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
