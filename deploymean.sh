#!/bin/bash
# A script to deploy an Angular project, by Michael K. https://github.com/mkemper31/

echo "--> What is your github username?"
read gitname
echo "--> What is your github repo name? Example: my_project"
read reponame
echo "--> What is this server's private IP?"
read ipaddress
echo "--> What port do you want to run your project on?"
read port
sudo apt-get update &&
sudo apt-get install -y build-essential openssl libssl-dev pkg-config &&
sudo apt-get install -y nodejs nodejs-legacy &&
sudo apt-get install npm -y &&
sudo npm cache clean -f &&
sudo npm install -g n &&
sudo n stable &&
sudo npm install -g @angular/cli &&
sudo apt-get install nginx git -y &&
cd /var/www &&
sudo git clone https://github.com/${gitname}/${reponame}.git &&
cd /etc/nginx/sites-available &&
touch ${reponame} &&
echo "server {
    listen 80;
    location / {
        proxy_pass http://${ipaddress}:${port};
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
        proxy_cache_bypass \$http_upgrade;
    }
}" | tee ${reponame} &&
sudo rm default &&
sudo ln -s /etc/nginx/sites-available/${reponame} /etc/nginx/sites-enabled/${reponame} &&
sudo rm /etc/nginx/sites-enabled/default &&
sudo npm install pm2 -g &&
cd /var/www &&
sudo chown -R ubuntu ${reponame} &&
cd ${reponame} &&
npm install &&
cd public &&
npm install &&
sudo ng build &&
wget -qO - https://www.mongodb.org/static/pgp/server-4.2.asc | sudo apt-key add - &&
echo "deb [ arch=amd64 ] https://repo.mongodb.org/apt/ubuntu xenial/mongodb-org/4.2 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-4.2.list &&
sudo apt-get update &&
sudo apt-get install -y mongodb-org &&
sudo mkdir /data &&
sudo mkdir /data/db &&
sudo systemctl enable mongod &&
sudo service mongod start &&
sudo systemctl start mongod &&
cd /var/www/${reponame} &&
pm2 start server.js &&
sudo service nginx stop && sudo service nginx start