# Run all the shell scripts in the sh folder

for f in $(ls ../shared-scripts/sh/); do . ../shared-scripts/sh/$f; done
source=""

case run-identify-shell in
  bash)
    echo "using bash aliases"
    source="${BASH_SOURCE[0]}"
    extra_folder="bash"
    ;;
  zsh)
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

eval $(run-get-source-and-dir "$source")

for f in $(ls $dir/sh/); do . $dir/sh/$f; done
if [ ! -z "$extrafolder" ]
  for f in $(ls $dir/$extra_folder/); do source $dir/$extra_folder/$f; done
fi
