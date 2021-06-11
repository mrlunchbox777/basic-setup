alias g='git'
alias pshell='pwsh'
alias snip='sharenix-section'
alias guid='uuid'
alias onenote="p3x-onenote"

cdssh()
{
	cd ~/.ssh
}

edit()
{
	code .
}

smbm()
{
	local remoteFolder=$1
	local localFolder=$2
	local sambaUsername=$3
	local sambaUid=$4

	if [ ! -d "$localFolder" ]; then
		mkdir "$localFolder"
	fi

	if [ -z "$username" ] && [ -z "$uid" ]; then
		sudo mount -t cifs "//$remoteFolder" "$localFolder"
	else	
		sudo mount -t cifs "//$remoteFolder" "$localFolder" -o sambaUsername="$username" sambaUid="$uid"
	fi
}

rgui()
{
	killall plasmashell && kstart5 plasmashell
}

startparsec()
{
	parsecd app_daemon=1
}
