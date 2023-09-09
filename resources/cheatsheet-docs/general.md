# General (Shared Scripts) Commands

## Commands

* `alias grepr='grep -r'`
* `alias guid='uuid'`
* `alias ll="ls -la"`
* `alias tf="terraform"`
* `alias tldr="tldr --auto-update-interval 10" # Update every 10 days`

* `alias cddev='general-cddev'`
* `alias count-lines-dir='general-count-lines-dir'`
* `alias dfind='general-dfind'`
* `alias diff-date='general-diff-date'`
* `alias ffind='general-ffind'`
* `alias get-shared-scripts-dir="general-get-shared-scripts-dir"`
* `alias get-source-and-dir="general-get-source-and-dir"`
* `alias get-sandd="get-source-and-dir"`
* `alias grepx='general-grepx'`
* `alias lsr='general-ls-recursive'`
* `alias random='general-random'`
* `alias read-script='general-read-script'`
* `alias iso-date='general-iso-date'`
* `alias send-message='general-send-message'`

```bash
function general-identify-shell-function-wrapper() {
	shared_scripts_dir=$(get-shared-scripts-dir)
	. "$shared_scripts_dir/bin/general-identify-shell-function"
	identify-shell-function
}
```
* `alias identify-shell='general-identify-shell-function-wrapper'`
