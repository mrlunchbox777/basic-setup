#! /usr/bin/env sh
# clones and installs the basic setup

current_dir="$(pwd)"
env_path=""

[ -f .env ] && env_path="$current_dir/.env"
mkdir -p "${HOME}/.basic-setup"
cd "${HOME}/.basic-setup"

if (( $(command -v bash >/dev/null 2>&1; echo $?) != 0 )); then
	echo "Please install bash before running this." >&2
	echo "See the following for details for windows https://itsfoss.com/install-bash-on-windows/" >&2
	echo "For mac and linux it should already be installed, but if not use your package manager."
fi
if (( $(command -v git >/dev/null 2>&1; echo $?) != 0 )); then
	echo "Please install git before running this." >&2
	echo "See the following for details https://git-scm.com/book/en/v2/Getting-Started-Installing-Git" >&2
	exit 1
fi

if [ ! -d basic-setup ]; then
	git clone https://github.com/mrlunchbox777/basic-setup
fi

cd basic-setup
basic_setup_dir="$(pwd)"
echo "current dir - $basic_setup_dir"
[ ! -z "$env_path" ] && cp "$env_path" ./.env
export PATH="$PATH:$(pwd)/shared-scripts/bin"
bash shared-scripts/basic-setup/init.sh | tee basic-setup-sh-output.log

## end of basic setup
echo "\n\n"
echo "**********************************************************"
echo "* Finished Basic Setup"
echo "*   Check -"
echo "*     $basic_setup_dir/basic-setup-sh-output.log"
echo "*   It will have logs and outputs on everything installed."
echo "**********************************************************"

cd "$current_dir"
