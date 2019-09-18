#!/bin/bash
# A script to create a new basic Angular project, by Michael K. https://github.com/mkemper31/

template_dir=~/Local_code/tracks/mean_stack/angular/angular_template
dir=$1
targetdir=$PWD/$dir/public
echo "--> What do you want your database to be called? Leave blank if you do not want to use a database connection."
read db
if [ ! -z "$db" ]
then
	echo "--> What do you want your first model to be named?"
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

mkdir $dir &&
cd $dir &&
npm init -y &&
npm i express &&
if [ ! -z "$db" ]
then
	npm i mongoose
fi
npm i express-session &&
npm i body-parser &&
touch server.js &&
echo "const app = require('./server/config/mongoose.js')
app.listen(8000, () => console.log('listening on port 8000'));
require('./server/config/routes.js')(app);" > server.js &&
mkdir server server/config server/controllers server/models &&
touch server/config/mongoose.js &&
echo "const express = require('express');
const app = express();
const session = require('express-session');
const path = require('path');
const bp = require('body-parser');" >> server/config/mongoose.js &&

if [ ! -z "$db" ]
then
	echo "const fs = require('fs');
const mongoose = require('mongoose');
mongoose.connect('mongodb://localhost/$db', {useNewUrlParser: true});
fs.readdirSync(path.join(__dirname, './../models')).forEach(function(file) {
    if(file.indexOf('.js') >= 0) {
        require(path.join(__dirname, './../models') + '/' + file);
    }
});" >> server/config/mongoose.js
fi

echo "app.use(express.urlencoded({extended: true}));
app.use(bp.urlencoded({ extended: false }))
app.use(bp.json())
app.use(express.static( path.join(__dirname, './../../public/dist/public')));
app.use(session({
    secret: 'thisisakey',
    resave: false,
    saveUninitialized: true,
    cookie: { maxAge: 60000 }
}));
module.exports = app;" >> server/config/mongoose.js
touch server/config/routes.js

if [ ! -z "$db" ]
then
	echo "const ${modellower}s = require('../controllers/${modellower}s.js');" >> server/config/routes.js
fi

echo "const path = require('path');
module.exports = (app) => {" >> server/config/routes.js
if [ ! -z "$db" ]
then
	echo "    // Get all ${modellower}s
    app.get('/${modellower}s', ${modellower}s.all);
    // Get one ${modellower} by ID
    app.get('/${modellower}s/:id', ${modellower}s.getOneById);
    // Create a new ${modellower}
    app.post('/${modellower}s/create', ${modellower}s.create);
    // Update a ${modellower} by ID, passing in data
    app.put('/${modellower}s/:id', ${modellower}s.update);
    // Delete a ${modellower} by ID
    app.delete('/${modellower}s/:id', ${modellower}s.delete);" >> server/config/routes.js
fi

echo "    // Catchall for malformed requests
    app.all('*', (req, res, next) => {
        res.sendFile(path.resolve('./public/dist/public/index.html'));
    });
}" >> server/config/routes.js
if [ ! -z "$db" ]
then
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
fi
mkdir public
cd public
sudo ditto -v $template_dir/* $PWD &&
cd .. &&
git init &&
sudo ditto -v $template_dir/.gitignore $PWD &&
osascript -e "tell application \"Terminal\" to do script \"cd $targetdir && ng build --watch\"" &&
code .
echo "https://github.com/mkemper31/"
