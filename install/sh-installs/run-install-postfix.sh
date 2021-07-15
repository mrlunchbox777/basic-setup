# run install postfix function
run-install-postfix-basic-setup () {
  if [ -z $(which postfix) ]; then
    # https://serverfault.com/questions/143968/automate-the-installation-of-postfix-on-ubuntu
    local mailname="$(domainname -A | awk '{print $1}')"
    debconf-set-selections <<< "postfix postfix/mailname string $mailname"
    debconf-set-selections <<< "postfix postfix/main_mailer_type string 'Local only'"
    sudo apt-get install --assume-yes postfix
  fi
}
