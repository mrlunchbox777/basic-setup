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
REGISTRY_PASSWORD=${BASIC_SETUP_INSTALL_FLUX_WRAPPER_REGISTRY_PASSWORD:-""}
REGISTRY_URL=${BASIC_SETUP_INSTALL_FLUX_WRAPPER_REGISTRY_URL:-""}
REGISTRY_USERNAME=${BASIC_SETUP_INSTALL_FLUX_WRAPPER_REGISTRY_USERNAME:-""}
SHOW_FULL_HELP=${BASIC_SETUP_INSTALL_FLUX_WRAPPER_SHOW_FULL_HELP:-""}
SHOW_HELP=false
USE_EXISTING_SECRET=${BASIC_SETUP_INSTALL_FLUX_WRAPPER_USE_EXISTING_SECRET:-""}
USE_REGISTRY_YAML=${BASIC_SETUP_INSTALL_FLUX_WRAPPER_USE_REGISTRY_YAML:-""}
VERBOSITY=${BASIC_SETUP_VERBOSITY:--1}
WAIT_TIMEOUT=${BASIC_SETUP_INSTALL_FLUX_WRAPPER_WAIT_TIMEOUT:--1}

#
# load environment variables
#
. basic-setup-set-env

#
# computed values (often can't be alphabetical)
#
if [ -z "$REGISTRY_PASSWORD" ]; then
	REGISTRY_PASSWORD=${BASIC_SETUP_INSTALL_FLUX_WRAPPER_REGISTRY_PASSWORD:-""}
fi
if [ -z "$REGISTRY_URL" ]; then
	REGISTRY_URL=${BASIC_SETUP_INSTALL_FLUX_WRAPPER_REGISTRY_URL:-"registry1.dso.mil"}
fi
if [ -z "$REGISTRY_USERNAME" ]; then
	REGISTRY_USERNAME=${BASIC_SETUP_INSTALL_FLUX_WRAPPER_REGISTRY_USERNAME:-""}
fi
if [ -z "$SHOW_FULL_HELP" ]; then
	SHOW_FULL_HELP=${BASIC_SETUP_INSTALL_FLUX_WRAPPER_SHOW_FULL_HELP:-false}
fi
if [ -z "$USE_EXISTING_SECRET" ]; then
	USE_EXISTING_SECRET=${BASIC_SETUP_INSTALL_FLUX_WRAPPER_USE_EXISTING_SECRET:-false}
fi
if [ -z "$USE_REGISTRY_YAML" ]; then
	USE_REGISTRY_YAML=${BASIC_SETUP_INSTALL_FLUX_WRAPPER_USE_REGISTRY_YAML:-true}
fi
if (( $VERBOSITY == -1 )); then
	VERBOSITY=${BASIC_SETUP_VERBOSITY:-0}
fi
if (( $WAIT_TIMEOUT == -1 )); then
	WAIT_TIMEOUT=${BASIC_SETUP_INSTALL_FLUX_WRAPPER_WAIT_TIMEOUT:-120}
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
		description: runs bb-install_flux.sh directly from the repo so that it doesn't fail
		----------
		wrapper flags:
		-h|--help    - (flag, current: $SHOW_HELP) Print this help message and exit.
		-m|--manual  - (flag, current: $USE_REGISTRY_YAML) Use prompting or other args to auth, instead of the default of using overrides/registry-values.yaml, also set with \`BASIC_SETUP_INSTALL_FLUX_WRAPPER_USE_REGISTRY_YAML\`.
		-v|--verbose - (multi-flag, default: $VERBOSITY) Increase the verbosity by 1, also set with \`BASIC_SETUP_VERBOSITY\`.
		--full-help  - (flag, current: $SHOW_FULL_HELP) Print the help message for install-flux.sh and exit with no error.

		script flags (all flags below are passed to bb-install_flux.sh):
		-h|--help                - print this help message and exit
		-r|--registry-url        - (optional, default: registry1.dso.mil) registry url to use for flux installation
		-s|--use-existing-secret - (optional) use existing private-registry secret
		-u|--registry-username   - (required) registry username to use for flux installation
		-p|--registry-password   - (optional, prompted if no existing secret) registry password to use for flux installation
		-w|--wait-timeout        - (optional, default: 120) how long to wait; in seconds, for each key flux resource component

		current values for the script flags:
		-h | --help                - $SHOW_HELP
		-r | --registry-url        - "$REGISTRY_URL", also set with \`BASIC_SETUP_INSTALL_FLUX_WRAPPER_REGISTRY_URL\`
		-s | --use-existing-secret - $USE_EXISTING_SECRET, also set with \`BASIC_SETUP_INSTALL_FLUX_WRAPPER_USE_EXISTING_SECRET\`
		-u | --registry-username   - "$REGISTRY_USERNAME", also set with \`BASIC_SETUP_INSTALL_FLUX_WRAPPER_REGISTRY_USERNAME\`
		-p | --registry-password   - "$(echo "$REGISTRY_PASSWORD" | sed 's/./*/g')", also set with \`BASIC_SETUP_INSTALL_FLUX_WRAPPER_REGISTRY_PASSWORD\`
		-w | --wait-timeout        - $WAIT_TIMEOUT, also set with \`BASIC_SETUP_INSTALL_FLUX_WRAPPER_WAIT_TIMEOUT\`
		----------
		note: everything under big-bang will be moved to https://repo1.dso.mil/big-bang/product/packages/bbctl eventually
		----------
		examples:
		run install flux reading yaml           - $command_for_help
		run install flux reading yaml show args - $command_for_help -v
		run install flux interactive            - $command_for_help -m
		----------
	EOF
}

# Builds the args to pass to bb-install_flux.sh
build-args() {
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
	if [ "$USE_REGISTRY_YAML" == true ]; then
		. big-bang-export-registry-credentials
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
	# manual auth flag
	-m | --manual)
		USE_REGISTRY_YAML=false
		shift
		;;
	# manual auth flag
	-s | --use-existing-secret)
		USE_EXISTING_SECRET=true
		shift
		;;
	# registry password, optional argument
	-p | --registry-password)
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
	-r | --registry-url)
		if [ -n "$2" ] && [ "${2:0:1}" != "-" ]; then
			REGISTRY_URL=$2
			shift 2
		else
			echo "Error: Argument for $1 is missing" >&2
			help
			exit 1
		fi
		;;
	# registry username, optional argument
	-u| --registry-username)
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
	-w | --wait-timeout)
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
if [ $SHOW_HELP == true ]; then
	help
	if [ $SHOW_FULL_HELP == false ]; then
		exit 0
	fi
fi

args="$(build-args)"
sed_string='s/-p .*\b/-p ******** /g'
(($VERBOSITY > 1)) && echo "sed_string: $sed_string"
args_string="$(echo "$args" | sed "$sed_string")"
(($VERBOSITY > 0)) && echo "args: $args_string"
command="$(readlink "$(command -v bb-install_flux.sh)")"
if [ -z "$command" ]; then
	echo "Error: bb-install_flux.sh not found, please run big-bang-relink-scripts" >&2
	help
	exit 1
fi
$command $args
