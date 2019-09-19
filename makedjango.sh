#!/bin/bash
# A script to create a new Django project, by Michael K. https://github.com/mkemper31/

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
echo "<!DOCTYPE html>
<html lang=\"en\">
    <head>
        <title>TODO</title>
        <meta charset=\"utf-8\">
        <meta name=\"description\" content=\"TODO\">
        <meta name=\"viewport\" content=\"width=device-width, initial-scale=1, shrink-to-fit=no\">
        <link rel=\"stylesheet\" href=\"https://stackpath.bootstrapcdn.com/bootstrap/4.3.1/css/bootstrap.min.css\" integrity=\"sha384-ggOyR0iXCbMQv3Xipma34MD+dH/1fQ784/j6cY/iJTQUOhcWr7x9JvoRxT2MZw1T\" crossorigin=\"anonymous\">
        <script src=\"https://ajax.googleapis.com/ajax/libs/jquery/3.4.1/jquery.min.js\"></script>
        <script src=\"https://cdnjs.cloudflare.com/ajax/libs/popper.js/1.14.7/umd/popper.min.js\" integrity=\"sha384-UO2eT0CpHqdSJQ6hJty5KVphtPhzWj9WO1clHTMGa3JDZwrnQq4sF86dIHNDz0W1\" crossorigin=\"anonymous\"></script>
        <script src=\"https://stackpath.bootstrapcdn.com/bootstrap/4.3.1/js/bootstrap.min.js\" integrity=\"sha384-JjSmVgyd0p3pXB1rRibZUAYoIIy6OrQ6VrjIEaFf/nJGzIxFDsf4x0xIM+B07jRM\" crossorigin=\"anonymous\"></script>
    </head>
    <body>
        <p>index html works!</p>
    </body>
</html>" >> templates/${appname}/index.html
cd ../..
open -a "Visual Studio Code" .
