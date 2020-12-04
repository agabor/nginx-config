#!/bin/bash
apt update
apt upgrade
apt install apache2 mariadb-server php libapache2-mod-php php-mysql php-curl php-gd php-mbstring php-xml php-xmlrpc php-soap php-intl php-zip
mysql -u root -e 'CREATE DATABASE wordpress DEFAULT CHARACTER SET utf8 COLLATE utf8_unicode_ci;'
mysql -u root -e "GRANT ALL ON wordpress.* TO 'wordpressuser'@'localhost' IDENTIFIED BY 'password';"
mysql -u root -e 'FLUSH PRIVILEGES;'
echo -e "<Directory /var/www/wordpress/>\n    AllowOverride All\n</Directory>" > wordpress.conf
mv wordpress.conf /etc/apache2/sites-available/wordpress.conf
a2enmod rewrite
apache2ctl configtest
systemctl restart apache2
cd /tmp
curl -O https://wordpress.org/latest.tar.gz
tar xzvf latest.tar.gz
touch /tmp/wordpress/.htaccess
cp /tmp/wordpress/wp-config-sample.php /tmp/wordpress/wp-config.php
mkdir /tmp/wordpress/wp-content/upgrade
cp -a /tmp/wordpress/. /var/www/wordpress
chown -R www-data:www-data /var/www/wordpress
find /var/www/wordpress/ -type d -exec chmod 750 {} \;
find /var/www/wordpress/ -type f -exec chmod 640 {} \;
cd /var/www/wordpress/
rm wp-config.php
git clone https://github.com/agabor/wpconfig.git
mv wpconfig/.git .
mv wpconfig/wp-config.php .
rm -rf wpconfig
