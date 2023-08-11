```bash
			discord \
			remmina \
			slack \
			spotify \
			teams \
            mattermost \
            k9s

general-send-message "Starting Manual Installs"
source ./sh-installs/run-manual-install.sh

[ "$should_install_ui_tools" == "true" ] && \
	run-manual-install-many-basic-setup \
		asbru \
		calibre \
		lens \
		lutris \
		steam \
		zoom

run-manual-install-many-basic-setup \
	azcli \
	dotnet \
	helm \
	k9s \
	kind \
	kubectl \
	mailutils \
	minikube \
	nvm \
	ohmyzsh \
	postfix \
	pwsh
```

# Add docker curl so that it can install on dnf
# Add a way to make kdeconnect work on Mac or skip it on mac (maybe labels?)
