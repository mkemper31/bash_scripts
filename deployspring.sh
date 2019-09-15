#!/bin/bash
# Designed to automate spring boot app deployment. By Michael K

appname=$1
description=$2

echo "Beginning deployment environment startup"
sudo apt-get -y upgrade && 
sudo apt-get install -y mysql-server && 
sudo apt-get install -y apache2 && 
sudo mkdir /var/springApp && 
sudo mv ~/$appname-0.0.1-SNAPSHOT.war /var/springApp
sudo a2enmod proxy && 
sudo a2enmod proxy_ajp && 
cd /etc/apache2/sites-available
echo "<VirtualHost *:80>
        # The ServerName directive sets the request scheme, hostname and port that
        # the server uses to identify itself. This is used when creating
        # redirection URLs. In the context of virtual hosts, the ServerName
        # specifies what hostname must appear in the request's Host: header to
        # match this virtual host. For the default virtual host (this file) this
        # value is not decisive as it is used as a last resort host regardless.
        # However, you must set it for any further virtual host explicitly.
        #ServerName www.example.com

        ServerAdmin webmaster@localhost
        DocumentRoot /var/www/html

        # Available loglevels: trace8, ..., trace1, debug, info, notice, warn,
        # error, crit, alert, emerg.
        # It is also possible to configure the loglevel for particular
        # modules, e.g.
        #LogLevel info ssl:warn

        ErrorLog \${APACHE_LOG_DIR}/error.log
        CustomLog \${APACHE_LOG_DIR}/access.log combined

        # For most configuration files from conf-available/, which are
        # enabled or disabled at a global level, it is possible to
        # include a line for only one particular virtual host. For example the
        # following line enables the CGI configuration for this host only
        # after it has been globally disabled with "a2disconf".
        #Include conf-available/serve-cgi-bin.conf
        ProxyPass / ajp://localhost:9090/
        ProxyPassReverse / ajp://localhost:9090/
</VirtualHost>

# vim: syntax=apache ts=4 sw=4 sts=4 sr noet" | sudo tee 000-default.conf && 
sudo service apache2 restart && 
sudo apt-get install -y default-jdk && 
cd /etc/systemd/system && 
sudo touch $appname.service && 
echo "[Unit]
Description=$description
After=syslog.target
[Service]
User=ubuntu
ExecStart=/usr/bin/java -jar /var/springApp/$appname-0.0.1-SNAPSHOT.war
SuccessExitStatus=143
[Install]
WantedBy=multi-user.target" | sudo tee $appname.service && 
sudo systemctl daemon-reload &&
echo "Enter mySQL password below (usually 'root')"
mysql -u root -p && 
sudo systemctl enable $appname.service && 
sudo systemctl start $appname && 
systemctl status $appname