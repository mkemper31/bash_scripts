#!/bin/bash
# A script to create a new basic Angular project, by Michael K. https://github.com/mkemper31/

template_dir=~/Local_code/tracks/mean_stack/angular/angular_template
dir=$1
targetdir=$PWD/$dir/public
secretkey=`cat /dev/urandom | env LC_CTYPE=C tr -cd 'a-z0-9' | head -c 16`
echo "--> What do you want your database to be called? Leave blank if you do not want to use a database connection."
read db
if [ ! -z "$db" ]
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
if [ ! -z "$db" ]
then
	npm i mongoose
fi
npm i express-session &&
npm i body-parser
touch server.js
if [ ! -z "$db" ]
then
    echo "require('./server/config/database');" >> server.js
fi
echo "const express = require('express');
const app = express();
const session = require('express-session');
const path = require('path');
const bp = require('body-parser');
app.use(express.urlencoded({extended: true}));
app.use(bp.urlencoded({ extended: false }))
app.use(bp.json())
app.use(express.static( path.join(__dirname, './public/dist/public')));
app.use(session({
    secret: '${secretkey}',
    resave: false,
    saveUninitialized: true,
    cookie: { maxAge: 60000 }
}));

const router = require('./server/routes');
app.use(router);

app.listen(8000, () => console.log('listening on port 8000'));" >> server.js
mkdir server server/config server/controllers server/models server/routes

if [ ! -z "$db" ]
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
touch server/routes/index.js
echo "const express = require('express');
const router = express.Router();" >> server/routes/index.js
if [ ! -z "$db" ]
then
    echo "const ${modellower}Routes = require('./${modellower}.routes');
router.use('/${modellower}s', ${modellower}Routes);" >> server/routes/index.js
fi
echo "module.exports = router;" >> server/routes/index.js
if [[ "$OSTYPE" == "darwin"* ]]; then
    mkdir public
    cd public
    sudo ditto -v $template_dir/* $PWD &&
    echo "Copy finished"
    cd ..
elif [[ "$OSTYPE" == "msys" ]]; then
    cp -R $template_dir\\public $PWD &&
    echo "Copy finished"
fi
git init &&
if [[ "$OSTYPE" == "darwin"* ]]; then
    if [ -f "${template_dir}/.gitignore" ]
    then
        sudo ditto -v $template_dir/.gitignore $PWD
    fi
elif [[ "$OSTYPE" == "msys" ]]; then
    if [ -f "${template_dir}\\.gitignore" ]
    then
        cp -v $template_dir\\.gitignore $PWD
    fi
fi
if [[ "$OSTYPE" == "darwin"* ]]
then
    osascript -e "tell application \"Terminal\" to do script \"cd $targetdir && ng build --watch\""
fi
code .
echo "https://github.com/mkemper31/"
