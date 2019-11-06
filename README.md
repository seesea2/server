# Bash Script to Setup Mail & Website Server

### Bash Script to setup web server (Nginx, nodejs, express) and email server (postfix, dovecot, postfixadmin, roundcube)

### make sure your use has sudo previlege:
usermod -aG sudo username

1. git clone this repository: `git clone https://github.com/seesea2/server.git`
2. enter the directory from terminal: `cd server`
3. configure file: **global.conf**
4. start installation by execute command: `bash setup.sh`

### then, set up postfiadmin at: pfa.site.com/setup.php
### then, set up webmail at: mail.site.com/installer

##### IMAP ssl://mail.site.com port 993
##### SMTP ssl://mail.site.com port 465
