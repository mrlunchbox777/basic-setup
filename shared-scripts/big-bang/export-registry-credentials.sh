# no crunch bang because this should be sourced

#
# helper functions
#

# script help message
zzz_helper_export_registry_credentials_help() {
	command_for_help="$(basename "$0")"
	cat <<- EOF
		----------
		usage: $command_for_help <arguments>
		----------
		description: A script that should be sourced to get the credentials for the bigbang registry from the overrides/registry-values.yaml file
		----------
		(There are no parameters to this script, it should be sourced)
		----------
		notes: exported variables below
		- export REGISTRY_USERNAME="\${REGISTRY_USERNAME:-}"
		- export REGISTRY_PASSWORD="\${REGISTRY_PASSWORD:-}"
		- export REGISTRY_URL="\${REGISTRY_URL:-}"
		----------
		examples:
		get the commands - . $command_for_help
		get the error output - . $command_for_help >$command_for_help.log 2>&1
		----------
	EOF
}

# Check if the script is being sourced
zzz_helper_export_registry_credentials_is_sourced() {
	if [ -n "$ZSH_VERSION" ]; then 
		case $ZSH_EVAL_CONTEXT in *:file:*) return 0;; esac
	else  # Add additional POSIX-compatible shell names here, if needed.
		case ${0##*/} in dash|-dash|bash|-bash|ksh|-ksh|sh|-sh) return 0;; esac
	fi
	local did_match=$(echo "$0" | grep -q ".*export\-registry\-credentials.*" >/dev/null 2>&1; echo $?)
	if [ $did_match -eq 0 ]; then
		return 1  # NOT sourced (file name matches this script).
	else
		return 0  # IS sourced.
	fi
}

# is null or whitespace
zzz_helper_export_registry_credentials_is_null_or_whitespace() {
	# TODO: fix this for zsh
	if [ -z "$1" ] || [ -z "${1// }" ] || [ -z "${1//	}" ] || [ -z "${1//\n}" ] || [ -z "${1//\r}" ] || [[ "$1" == "null" ]]; then
		return 0
	else
		return 1
	fi
}

#
# Do the work
#
zzz_helper_export_registry_credentials_is_sourced || { echo "Error: This script should be sourced, not run." >&2; zzz_helper_export_registry_credentials_help; exit 1; }

override_dir="$(big-bang-get-repo-dir)/../overrides"
if [ ! -d "$override_dir" ]; then
	echo "Error: $override_dir does not exist" >&2
	zzz_helper_export_registry_credentials_help
	exit 1
fi
override_dir="$(cd "$override_dir" && pwd)"

registry_creds_file="$override_dir/registry-values.yaml"
if [ ! -f "$registry_creds_file" ]; then
	echo "Error: $registry_creds_file does not exist" >&2
	zzz_helper_export_registry_credentials_help
	exit 1
fi

registry_creds="$(yq .registryCredentials "$registry_creds_file")"

if zzz_helper_export_registry_credentials_is_null_or_whitespace "$registry_creds"; then
	echo "Error: .registryCredentials in $registry_creds_file is null or whitespace" >&2
	zzz_helper_export_registry_credentials_help
	exit 1
fi

harbor_user="$(yq .registryCredentials.username "$registry_creds_file")"
if zzz_helper_export_registry_credentials_is_null_or_whitespace "$harbor_user"; then
	echo "Error: .registryCredentials.username in $registry_creds_file is null or whitespace" >&2
	zzz_helper_export_registry_credentials_help
	exit 1
fi

harbor_password="$(yq .registryCredentials.password "$registry_creds_file")"
if zzz_helper_export_registry_credentials_is_null_or_whitespace "$harbor_password"; then
	echo "Error: .registryCredentials.password in $registry_creds_file is null or whitespace" >&2
	zzz_helper_export_registry_credentials_help
	exit 1
fi

harbor_registry="$(yq .registryCredentials.registry "$registry_creds_file")"
if zzz_helper_export_registry_credentials_is_null_or_whitespace "$harbor_registry"; then
	echo "Error: .registryCredentials.registry in $registry_creds_file is null or whitespace" >&2
	zzz_helper_export_registry_credentials_help
	exit 1
fi

export REGISTRY_USERNAME="$harbor_user"
export REGISTRY_PASSWORD="$harbor_password"
export REGISTRY_URL="$harbor_registry"
