if ! id -u vmail >/dev/null 2>&1; then
	sudo useradd -m vmail
    sudo mkdir /var/mail/vmail
    sudo chown vmail: /etc/mail/vmail
fi
