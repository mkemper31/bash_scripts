#!/bin/bash
# A script to create a new Django project, by Michael K
# example usage: 
# sh newproject.sh django_intro/ my_first_project my_first_app

desiredargs=3
dir=$1
projname=$2
appname=$3

if [ $# -eq $desiredargs ]
then
	if [ -d $dir ]
	then
		echo "Beginning script to start a new project with 1 app"
		cd $dir
		django-admin startproject $projname
		cd $projname
		mkdir apps
		cd apps
		python ../manage.py startapp $appname
		cd $appname
		touch urls.py
		mkdir templates templates/$appname static static/$appname static/$appname/css static/$appname/js static/$appname/images
		touch templates/$appname/index.html static/$appname/css/style.css
		echo "Ended new project script! Don't forget to add your apps and routes to the appropriate files."
		echo "Opening in visual studio code..."
		cd ../..
		open -a "Visual Studio Code" .
	else
		echo "Error: No directory found! Check spelling on first argument. Exiting..."
	fi
else
	echo "Not enough arguments provided! Exiting..."
fi