#!/bin/bash
# A script to create a new Django project, by Michael K

echo "What do you want to name the project?"
read projname
echo "What do you want to name the app?"
read appname

django-admin startproject ${projname}
cd ${projname}
mkdir apps
cd apps
python ../manage.py startapp ${appname}
cd ${appname}
touch urls.py
mkdir templates templates/${appname} static static/${appname} static/${appname}/css static/${appname}/js static/${appname}/images
touch templates/${appname}/index.html static/${appname}/css/style.css static/${appname}/js/script.js
cd ../..
open -a "Visual Studio Code" .
