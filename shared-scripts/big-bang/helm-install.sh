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
COMBINED_YAML_FILES=()
EXCLUDE_DEFAULT_YAML=${BAISC_SETUP_BIG_BANG_HELM_INSTALL_EXCLUDE_DEFAULT_YAML:-""}
INSTALL_COMMAND=""
OVERRIDE_FILES=()
SHOW_HELP=false
VERBOSITY=${BASIC_SETUP_VERBOSITY:--1}
YAML_FILES=()

#
# load environment variables
#
. basic-setup-set-env

#
# computed values (often can't be alphabetical)
#
if [ -z "$EXCLUDE_DEFAULT_YAML" ]; then
	EXCLUDE_DEFAULT_YAML=${BAISC_SETUP_BIG_BANG_HELM_INSTALL_EXCLUDE_DEFAULT_YAML:-false}
fi
if (( $VERBOSITY == -1 )); then
	VERBOSITY=${BASIC_SETUP_VERBOSITY:-0}
fi
BIG_BANG_DIR="$(big-bang-get-repo-dir)"
YAML_FILES_ARGS=""

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
		description: runs helm install scripts
		----------
		-c|--install-command      - (flag, current: \"$INSTALL_COMMAND\") name of install script in the override dir, this runs instead of the generic bigbang deploy.
		-e|--exclude-default-yaml - (flag, current: $EXCLUDE_DEFAULT_YAML) Don't include the default yaml files (listed below), also set with \`BAISC_SETUP_BIG_BANG_HELM_INSTALL_EXCLUDE_DEFAULT_YAML\`.
		-f|--yaml-file            - (multi-option, current: (${YAML_FILES[@]})) Any number of yaml files in the override dir to include with -f on the install command, e.g. ~/extra-value.yaml.
		-h|--help                 - (flag, current: $SHOW_HELP) Print this help message and exit.
		-o|--override-files       - (multi-option, current: (${OVERRIDE_FILES[@]})) Any number of files in the override dir to include with -f on the install command, e.g. registry-values.yaml.
		-v|--verbose              - (multi-flag, current: $VERBOSITY) Increase the verbosity by 1, also set with \`BASIC_SETUP_VERBOSITY\`.
		----------
		note: first the default yaml files are added (unless excluded), then -f files are added in the order they are specified, then -o files are added in the order they are specified.
		  default yaml files (in order): chart/ingress-certs.yaml, docs/assets/configs/example/policy-overrides-k3d.yaml, docs/assets/configs/example/dev-sso-values.yaml, ../overrides/registry-values.yaml
		  default then -f then -o
		note: everything under big-bang will be moved to https://repo1.dso.mil/big-bang/product/packages/bbctl eventually
		----------
		examples:
		run basic big bang install                     - $command_for_help
		run an install script called metrics-server.sh - $command_for_help -c metrics-server.sh
		run basic big bang install with an override    - $command_for_help -o default-disables.yaml
		----------
	EOF
}

# add the yaml files to the array
add-yaml-files() {
	if [ "$EXCLUDE_DEFAULT_YAML" == false ]; then
		COMBINED_YAML_FILES+=("$(realpath "${BIG_BANG_DIR}/chart/ingress-certs.yaml")")
		COMBINED_YAML_FILES+=("$(realpath "${BIG_BANG_DIR}/docs/assets/configs/example/policy-overrides-k3d.yaml")")
		COMBINED_YAML_FILES+=("$(realpath "${BIG_BANG_DIR}/docs/assets/configs/example/dev-sso-values.yaml")")
		COMBINED_YAML_FILES+=("$(realpath "${BIG_BANG_DIR}/../overrides/registry-values.yaml")")
	fi

	for yaml_file in "${YAML_FILES[@]}"; do
		COMBINED_YAML_FILES+=("$(realpath "$yaml_file")")
	done

	for yaml_file in "${OVERRIDE_FILES[@]}"; do
		COMBINED_YAML_FILES+=("$(realpath "${BIG_BANG_DIR}/../overrides/$yaml_file")")
	done

	for yaml_file in "${COMBINED_YAML_FILES[@]}"; do
		YAML_FILES_ARGS="$YAML_FILES_ARGS -f $yaml_file"
	done
}

# run the helm command
run-the-helm-command() {
	if [ "$INSTALL_COMMAND" != "" ]; then
		install_command="$(realpath $BIG_BANG_DIR/../overrides/$INSTALL_COMMAND)"
		if [ ! -f "$install_command" ]; then
			echo "Error: $install_command does not exist" >&2
			help
			exit 1
		fi
		(($VERBOSITY > 0)) && echo "running - $install_command $YAML_FILES_ARGS"
		$install_command $YAML_FILES_ARGS
	else
		(($VERBOSITY > 0)) && echo "running - helm upgrade -i bigbang \"${BIG_BANG_DIR}/chart/\" -n bigbang --create-namespace $YAML_FILES_ARGS"
		helm upgrade -i bigbang "${BIG_BANG_DIR}/chart/" -n bigbang --create-namespace $YAML_FILES_ARGS
	fi
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

add-yaml-files
run-the-helm-command
