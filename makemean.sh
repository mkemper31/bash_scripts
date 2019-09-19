#!/bin/bash
# A script to create a new basic Angular project, by Michael K. https://github.com/mkemper31/

# Fill in your template directory before use. Point this variable at a directory holding a boilerplate Angular public folder.
# Example: ~/my_code/angular_template
# Inside ~/my_code/angular_template should be an Angular folder called `public`
ang_folder_name=public
response=y
copy=true
dir=$1
template_dir=""
secretkey=`cat /dev/urandom | env LC_CTYPE=C tr -cd 'a-z0-9' | head -c 16`
if [ -z "$template_dir" ]; then
    echo "WARN: You did not specify an Angular template directory. Script will not copy an angular template; you will need to manually install it with ng new."
    copy=false
fi
echo $copy
if [ -n "$template_dir" && "$copy" == "true" ]; then
    if [[ "$OSTYPE" == "darwin"* ]]; then
        if [ ! -f "${template_dir}/${ang_folder_name}" ]; then
            echo "WARN: folder \"${ang_folder_name}\" not found in template directory."
            read -e -p "Specify new angular folder name? [y/n] " response; : "${response:=y}"
            if [[ "$response" == "y" ]]; then
                read -e -p "New angular folder name: " ang_folder_name
                if [ ! -f "${template_dir}/${ang_folder_name}" ]; then
                    echo "No folder found. Exiting..."
                    exit 1
                fi
            elif [[ "$response" == "n" ]]; then
                echo "No angular template folder will be copied."
                copy=false
            else
                echo "Invalid response. Exiting..."
                exit 1
            fi
        fi
    elif [[ "$OSTYPE" == "msys" ]]; then
        if [ ! -f "${template_dir}\\${ang_folder_name}" ]; then
            echo "WARN: folder \"${ang_folder_name}\" not found in template directory."
            read -e -p "Specify new angular folder name? [y/n] " response; : "${response:=y}"
            if [[ "$response" == "y" ]]; then
                read -e -p "New angular folder name: " ang_folder_name
                if [ ! -f "${template_dir}\\${ang_folder_name}" ]; then
                    echo "No folder found. Exiting..."
                    exit 1
                fi
            elif [[ "$response" == "n" ]]; then
                echo "No angular template folder will be copied."
                copy=false
            else
                echo "Invalid response. Exiting..."
                exit 1
            fi
        fi
    fi
fi
targetdir=$PWD/$dir/$ang_folder_name
echo "--> What do you want your database to be called? Leave blank if you do not want to use a database connection."
read db
if [ -n "$db" ]
then
    echo "--> What do you want your first model to be named? Use a singular noun (eg. author)"
    read model
    if [ -z "$model" ]
    then
        echo "Model name not provided! Exiting..."
        exit 1
    else
        modelupper="$(tr '[:lower:]' '[:upper:]' <<< ${model:0:1})${model:1}"
        modellower="$(tr '[:upper:]' '[:lower:]' <<< ${model:0:1})${model:1}"
    fi
fi

mkdir $dir
cd $dir
npm init -y &&
npm i express &&
if [ -n "$db" ]
then
	npm i mongoose
fi
npm i express-session &&
npm i body-parser
if [[ "$copy" == "true" ]]; then
    if [[ "$OSTYPE" == "darwin"* ]]; then
        mkdir ${ang_folder_name}
        cd ${ang_folder_name}
        sudo ditto -v $template_dir/* $PWD &&
        echo "Copy finished"
        cd ..
    elif [[ "$OSTYPE" == "msys" ]]; then
        cp -R $template_dir\\${ang_folder_name} $PWD &&
        echo "Copy finished"
    fi
else
    read -e -p "No Angular template was copied. Would you like to specify one now? [y/n] " response; : "${response:=y}"
    if [[ "$response" == "y" ]]; then
        read -e -p "Specify name to pass to 'ng new' command (default: public): " ang_folder_name; : "${ang_folder_name:=public}"
        ng new ${ang_folder_name} &&
        cd ${ang_folder_name}
        rm -rf .git*
        cd ..
    fi
fi
touch server.js
if [ -n "$db" ]
then
    echo "require('./server/config/database');" >> server.js
fi
echo "const express = require('express');
const app = express();
const session = require('express-session');
const path = require('path');
const bp = require('body-parser');
const router = require('./server/routes');
app.use(express.urlencoded({extended: true}));
app.use(bp.urlencoded({ extended: false }))
app.use(bp.json())
app.use(express.static( path.join(__dirname, './${ang_folder_name}/dist/${ang_folder_name}')));
app.use(session({
    secret: '${secretkey}',
    resave: false,
    saveUninitialized: true,
    cookie: { maxAge: 60000 }
}));
app.use(router);

app.listen(8000, () => console.log('listening on port 8000'));" >> server.js
mkdir server server/config server/controllers server/models server/routes

if [ -n "$db" ]
then
    touch server/config/database.js
    echo "const path = require('path');
const fs = require('fs');
const mongoose = require('mongoose');
mongoose.connect('mongodb://localhost/${modellower}s', {useNewUrlParser: true});
fs.readdirSync(path.join(__dirname, './../models')).forEach(function(file) {
    if(file.indexOf('.js') >= 0) {
        require(path.join(__dirname, './../models') + '/' + file);
    }
});" >> server/config/database.js
	  touch server/controllers/${modellower}s.js
	  echo "const mongoose = require('mongoose');
const ${modelupper} = mongoose.model('${modelupper}')
module.exports = {
    all: async (req, res) => {
        try {
            const ${modellower}s = await ${modelupper}.find();
            res.json({${modellower}s: ${modellower}s});
        }
        catch (err) {
            res.json(err);
        }
    },
    getOneById: (req, res) => {
        ${modelupper}.findById({ _id : req.params.id })
            .then((data) => {
                res.json({${modellower}: data})
            })
            .catch(err => res.json(err));
    },
    create: (req, res) => {
        const ${modellower} = new ${modelupper}(req.body);
        ${modellower}.save()
            .then((data) => {
                res.json({new${modelupper}: data});
            })
            .catch(err => res.json(err));
    },
    update: (req, res) => {
        ${modelupper}.updateOne({ _id : req.params.id }, req.body)
            .then((data) => {
                res.json({updated${modelupper}: data});
            })
            .catch(err => res.json(err));
    },
    delete: (req, res) => {
        ${modelupper}.findOneAndDelete({ _id : req.params.id })
            .then((data) => {
                res.json(data);
            })
            .catch(err => {
                res.json(err);
            });
    },
}" | tee server/controllers/${modellower}s.js
	  touch server/models/${modellower}.js
	  echo "const mongoose = require('mongoose');
const ${modelupper}Schema = new mongoose.Schema({
    title: { type: String, required: true},
    description: { type: String, default: '', },
}, {timestamps: true });
mongoose.model('${modelupper}', ${modelupper}Schema);" | tee server/models/${modellower}.js
    touch server/routes/${modellower}.routes.js
    echo "const express = require('express');
const router = express.Router();
const ${modellower}s = require('./../controllers/${modellower}s');

router.get('/', ${modellower}s.all)
    .get('/:id', ${modellower}s.getOneById)
    .post('/', ${modellower}s.create)
    .put('/:id', ${modellower}s.update)
    .delete('/:id', ${modellower}s.delete)

module.exports = router;" | tee server/routes/${modellower}.routes.js
fi
touch server/routes/catchall.routes.js
echo "const express = require('express');
const path = require('path');
const router = express.Router();

router.all('*', (req, res, next) => {
  res.sendFile(path.resolve('./${ang_folder_name}/dist/${ang_folder_name}/index.html'));
});

module.exports = router;" >> server/routes/catchall.routes.js
touch server/routes/index.js
echo "const express = require('express');
const router = express.Router();
const catchallRoute = require('./catchall.routes');" >> server/routes/index.js
if [ -n "$db" ]
then
    echo "const apiRouter = express.Router();
const ${modellower}Routes = require('./${modellower}.routes');
apiRouter.use('/${modellower}s', ${modellower}Routes);
router.use('/api', apiRouter)
  .use(catchallRoute);" >> server/routes/index.js
else
    echo "router.use(catchallRoute);" >> server/routes/index.js
fi

echo "module.exports = router;" >> server/routes/index.js
git init &&
if [[ "$OSTYPE" == "darwin"* ]]; then
    if [ -f "${template_dir}/.gitignore" ]
    then
        sudo ditto -v $template_dir/.gitignore $PWD
    else
        touch .gitignore
        echo "node_modules" >> .gitignore
    fi
elif [[ "$OSTYPE" == "msys" ]]; then
    if [ -f "${template_dir}\\.gitignore" ]
    then
        cp -v $template_dir\\.gitignore $PWD
    else
        echo "node_modules" >> .gitignore
    fi
fi
if [[ "$OSTYPE" == "darwin"* && "$copy" == "true" ]]
then
    osascript -e "tell application \"Terminal\" to do script \"cd $targetdir && ng build --watch\""
fi
code .
echo "https://github.com/mkemper31/"
