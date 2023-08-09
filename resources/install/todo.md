```bash
[ $should_install_ui_tools == "true" ] && \
	run-manual-install-apt-many-basic-setup \
		firefox \
		gimp \
		grpn \
		kdeconnect \
		kleopatra \
		libreoffice \
		thunderbird \
		virtualbox \
		vlc \
		wine

run-manual-install-apt-many-basic-setup \
	golang \
	gpg \
	make \
	openjdk \
	openssh-client \
	python3 \
	ranger \
	terraform \
	tldr \
	tmux \
	uuid \
	wget \

if [ $should_install_snap == "true" ]; then
	general-send-message "Starting snap Installs"
	source sh-installs/run-manual-install-snap.sh

	[ $should_install_ui_tools == "true" ] && \
		run-manual-install-snap-many-basic-setup \
			discord \
			remmina \
			slack \
			spotify \
			teams
else
	general-send-message "Skipping snap Installs"
fi

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
		code \
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

[ "$should_install_ui_tools" == "true" ] && \
	run-manual-update-many-basic-setup \
		code

run-manual-update-many-basic-setup \
	"alias" \
	batcat \
	gitconfig \
	unattended-upgrades
```
