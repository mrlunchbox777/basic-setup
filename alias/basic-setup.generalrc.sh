# Run all the shell scripts in the sh folder
shared_scripts_path="../shared-scripts"
[ ! -d "$shared_scripts_path" ] && shared_scripts_path="./shared-scripts"
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
for basic_setup_generalrc_sh_f in $(ls -p "$shared_scripts_path/sh/" | grep -v /); do
  . "$shared_scripts_path/sh/$basic_setup_generalrc_sh_f"
done
source=""

export CURRENT_SHELL="$(run-identify-shell-basic-setup | sed -r 's/[\ -]//g' )"
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

run-get-source-and-dir "$source"
source="${rgsd[@]:0:1}"
dir="${rgsd[@]:1:1}"
export BASICSETUPGENERALRCDIR="$dir"

for basic_setup_generalrc_sh_f in $(ls -p $dir/sh/ | grep -v /); do . $dir/sh/$basic_setup_generalrc_sh_f; done
if [ -d "$dir/$extra_folder/" ]; then
  for basic_setup_generalrc_sh_f in $(ls -p $dir/$extra_folder/ | grep -v /); do source $dir/$extra_folder/$basic_setup_generalrc_sh_f; done
fi

export BASICSETUPGENERALRCDIR="$dir"
export BASICSETUPGENERALRCHASRUN=true
