# Run all the shell scripts in the sh folder (this is a duplicate of the shared-scripts/general/get-shared-scripts-dir.sh)
shared_scripts_path="../shared-scripts"
[ ! -d "$shared_scripts_path" ] && shared_scripts_path="$(cd $(dirname ./shared-scripts) && pwd -P)/shared-scripts"
[ ! -d "$shared_scripts_path" ] && shared_scripts_path=$(find $HOME/src/tools -type d -wholename "*basic-setup/shared-scripts")
[ ! -d "$shared_scripts_path" ] && shared_scripts_path=$(find ./ -type d -wholename "*basic-setup/shared-scripts")
[ ! -d "$shared_scripts_path" ] && shared_scripts_path=$(find $HOME/src -type d -wholename "*basic-setup/shared-scripts")
[ ! -d "$shared_scripts_path" ] && shared_scripts_path=$(find $HOME/ -type d -wholename "*basic-setup/shared-scripts")
[ ! -d "$shared_scripts_path" ] && shared_scripts_path=$(find /home/ -type d -wholename "*basic-setup/shared-scripts")
[ ! -d "$shared_scripts_path" ] && shared_scripts_path=$(find / -type d -wholename "*basic-setup/shared-scripts")
if [ ! -d "$shared_scripts_path" ]; then
		echo -e "error finding shared-scripts..." >&2
		exit 1
fi

# Include the shared-scripts/bin in the PATH
export PATH="$shared_scripts_path/bin:$PATH"
# Include the shared-scripts/big-bang/bin in the PATH
export PATH="$shared_scripts_path/big-bang/bin:$PATH"
# Include the shared-scripts/alias in the PATH
export PATH="$shared_scripts_path/alias/bin:$PATH"

source=""

. "$shared_scripts_path/bin/general-identify-shell-function"
export CURRENT_SHELL="$(identify-shell-function | sed -r 's/[\ -]//g' )"
echo "shell - $CURRENT_SHELL"

case "$CURRENT_SHELL" in
	"bash")
		echo "using bash aliases"
		source="${BASH_SOURCE[0]}"
		extra_folder="bash"
		;;
	"zsh")
		echo "using zsh aliases"
		source="${(%):-%x}"
		extra_folder="zsh"
		;;
	*)
		echo "using sh aliases"
		source="$0"
		extra_folder=""
		;;
esac

sd="$(general-get-source-and-dir "$source")"
source="$(echo "$sd" | jq -r .source)"
dir="$(echo "$sd" | jq -r .dir)"
export BASICSETUPGENERALRCDIR="$dir"

if [ -d "$dir/sh/" ]; then
	for basic_setup_generalrc_sh_f in $(ls -p $dir/sh/ | grep -v /); do
		. $dir/sh/$basic_setup_generalrc_sh_f
	done
fi
if [ -d "$dir/$extra_folder/" ]; then
	for basic_setup_generalrc_sh_f in $(ls -p $dir/$extra_folder/ | grep -v /); do
		. $dir/$extra_folder/$basic_setup_generalrc_sh_f
	done
fi

export BASICSETUPGENERALRCDIR="$dir"
export BASICSETUPGENERALRCHASRUN=true
if [[ "$(general-command-installed bat)" == "true" ]]; then
	export MANPAGER="sh -c 'col -bx | bat -l man -p'"
fi
