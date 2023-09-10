# This must be an alias because as a script alias it creates an infinite loop
alias tldr="tldr --auto-update-interval 10" # Update every 10 days

# This must be a sourced function because a script creates a new shell rather than reading the current one
function general-identify-shell-function-wrapper() {
	shared_scripts_dir=$(get-shared-scripts-dir)
	. "$shared_scripts_dir/bin/general-identify-shell-function"
	identify-shell-function
}
alias identify-shell='general-identify-shell-function-wrapper'

# This must be a sourced function because a script creates a new shell (and alias context) rather than reading the current one
function general-how-function-wrapper() {
	shared_scripts_dir=$(get-shared-scripts-dir)
	. "$shared_scripts_dir/bin/general-how-function"
	how-function $@
}
alias howa='general-how-function-wrapper'
