# add this to your ~/.bashrc
# source ~/.ssh/Alias/.bashrc

source ~/.ssh/Alias/sh/git.bashrc.sh
source ~/.ssh/Alias/sh/primary.bash_aliases.sh
source ~/.ssh/Alias/sh/private.bashrc.sh
source ~/.ssh/Alias/sh/env-var.bashrc.sh
source ~/.ssh/Alias/sh/mount.bashrc.sh

# ls Alias/sh | sed "s/.*/~\/src\/tools\/basic-setup\/Alias\/sh\/&/" | xargs --no-run-if-empty -I _ source _