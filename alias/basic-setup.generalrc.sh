# Run all the shell scripts in the sh folder

shared_scripts_path="../shared-scripts"
[ ! -d "$shared_scripts_path" ] && shared_scripts_path="./shared-scripts"
[ ! -d "$shared_scripts_path" ] && shared_scripts_path=$(find ./ -type d -wholename "*basic-setup/shared-scripts")
[ ! -d "$shared_scripts_path" ] && shared_scripts_path=$(find / -type d -wholename "*basic-setup/shared-scripts")
if [ ! -d "$shared_scripts_path" ]; then
    echo -e "error finding shared-scripts..." >&2
    exit 1
fi
for f in $(ls "$shared_scripts_path/sh/"); do . "$shared_scripts_path/sh/$f"; done
source=""

export SHELL="$(run-identify-shell-basic-setup)"
echo "shell - $SHELL"

case "$SHELL" in
  "bash"|"-bash"|" -bash")
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

for f in $(ls $dir/sh/); do . $dir/sh/$f; done
if [ ! -z "$extrafolder" ]; then
  for f in $(ls $dir/$extra_folder/); do source $dir/$extra_folder/$f; done
fi
