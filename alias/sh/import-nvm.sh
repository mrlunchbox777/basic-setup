# pulled from https://github.com/nvm-sh/nvm#git-install
export NVM_DIR="$HOME/.nvm"

if [ -d "$NVM_DIR" ]; then
	[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" || echo "nvm.sh not found, skipping..." >&2                                # This loads nvm
	[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion" || echo "nvm bash_completion not found, skipping..." >&2 # This loads nvm bash_completion
else
	echo "Unable to find \"\$NVM_DIR\" ($NVM_DIR), skipping..." >&2
fi
