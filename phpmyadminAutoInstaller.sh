#!/bin/bash

##Update
apt-get install pwgen -y
apt update && apt upgrade -y

##HauptPakete lol
apt install -y ca-certificates apt-transport-https lsb-release gnupg curl nano unzip apache2 mariadb-server mariadb-client php7.4 php7.4-cli php7.4-common php7.4-curl php7.4-gd php7.4-intl php7.4-json php7.4-mbstring php7.4-mysql php7.4-opcache php7.4-readline php7.4-xml php7.4-xsl php7.4-zip php7.4-bz2 libapache2-mod-php7.4

##PHPMyAdmin herunterladen und konfigurieren
cd /usr/share
wget -q https://www.phpmyadmin.net/downloads/phpMyAdmin-latest-all-languages.zip -O phpmyadmin.zip
unzip phpmyadmin.zip && rm phpmyadmin.zip
mv phpMyAdmin-*-all-languages phpmyadmin
chmod -R 0755 phpmyadmin

cat <<EOF >/etc/apache2/conf-available/phpmyadmin.conf
Alias /phpmyadmin /usr/share/phpmyadmin
<Directory /usr/share/phpmyadmin>
Options SymLinksIfOwnerMatch
DirectoryIndex index.php
</Directory>
<Directory /usr/share/phpmyadmin/templates>
Require all denied
</Directory>
<Directory /usr/share/phpmyadmin/libraries>
Require all denied
</Directory>
<Directory /usr/share/phpmyadmin/setup/lib>
Require all denied
</Directory>
EOF

a2enconf phpmyadmin
systemctl reload apache2
mkdir /usr/share/phpmyadmin/tmp/
chown -R www-data:www-data /usr/share/phpmyadmin/tmp/

##MySQL konfigurieren und User erstellen
PASS=$(pwgen -s 40 1)
mysql <<MYSQL_SCRIPT
CREATE USER 'fivem'@'localhost' IDENTIFIED BY '$PASS';
GRANT ALL PRIVILEGES ON . TO 'fivem'@'localhost' WITH GRANT OPTION;
FLUSH PRIVILEGES;
MYSQL_SCRIPT

ip=$(hostname -i)

##Installations-Log / Zugangsdaten erstellen
cat <<EOF >/root/phpmyadmin-data.txt
######### PHPMYADMIN Zugang #########
Link: http://$ip/phpmyadmin
User: fivem
Passwort: $PASS
EOF