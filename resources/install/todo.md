```bash
			discord \
			remmina \
			slack \
			spotify \
			teams \
            mattermost

general-send-message "Starting git submodule update"
[ "$should_do_submodule_update" == "true" ] && \
	git-submodule-update-all

general-send-message "Starting Manual Installs"
source ./sh-installs/run-manual-install.sh

[ "$should_install_ui_tools" == "true" ] && \
	run-manual-install-many-basic-setup \
		asbru \
		azuredatastudio \
		calibre \
		lens \
		lutris \
		steam \
		virtualboxextpack \
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
