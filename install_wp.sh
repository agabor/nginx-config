#!/bin/bash
apt-get update
apt-get -y upgrade
apt-get -y install apache2 mariadb-server php libapache2-mod-php php-mysql php-curl php-gd php-mbstring php-xml php-xmlrpc php-soap php-intl php-zip git unzip php-fpm
mysql -u root -e 'CREATE DATABASE wordpress DEFAULT CHARACTER SET utf8 COLLATE utf8_unicode_ci;'
mysql -u root -e "GRANT ALL ON wordpress.* TO 'wordpressuser'@'localhost' IDENTIFIED BY 'password';"
mysql -u root -e 'FLUSH PRIVILEGES;'
echo -e "<Directory /var/www/wordpress/>\n    AllowOverride All\n</Directory>" | tee /etc/apache2/sites-available/wordpress.conf
a2enmod rewrite
mv /etc/apache2/ports.conf /etc/apache2/ports.conf.default
echo "Listen 8080" | sudo tee /etc/apache2/ports.conf
a2dissite 000-default
echo -e "<VirtualHost *:8080>\n    ServerAdmin webmaster@localhost\n    DocumentRoot /var/www/html\n    ErrorLog ${APACHE_LOG_DIR}/error.log\n    CustomLog ${APACHE_LOG_DIR}/access.log combined\n</VirtualHost>" | tee /etc/apache2/sites-available/001-default.conf
a2ensite 001-default
apache2ctl configtest
systemctl restart apache2

exit

a2enmod actions
mv /etc/apache2/mods-enabled/fastcgi.conf /etc/apache2/mods-enabled/fastcgi.conf.default
echo -e "<IfModule mod_fastcgi.c>\n  AddHandler fastcgi-script .fcgi\n  FastCgiIpcDir /var/lib/apache2/fastcgi\n  AddType application/x-httpd-fastphp .php\n  Action application/x-httpd-fastphp /php-fcgi\n  Alias /php-fcgi /usr/lib/cgi-bin/php-fcgi\n  FastCgiExternalServer /usr/lib/cgi-bin/php-fcgi -socket /run/php/php7.2-fpm.sock -pass-header Authorization\n  <Directory /usr/lib/cgi-bin>\n    Require all granted\n  </Directory>\n</IfModule>" | tee /etc/apache2/mods-enabled/fastcgi.conf
apachectl -t
systemctl reload apache2
echo "<?php phpinfo(); ?>" | sudo tee /var/www/html/info.php
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
cd /tmp
sudo wget https://codesharp.hu/custom-nginxlight.zip
unzip custom-nginxlight.zip
