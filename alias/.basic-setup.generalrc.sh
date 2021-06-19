# Run all the shell scripts in the sh folder

for f in $(ls ../shared-scripts/sh/); do source ../shared-scripts/sh/$f; done
source="${BASH_SOURCE[0]}"
eval $(run-get-source-and-dir "$source")

for f in $(ls $dir/sh/); do source $dir/sh/$f; done
