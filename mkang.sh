#!/bin/bash
# A script to create a new basic Angular project, by Michael K

template_dir=~/Local_code/tracks/mean_stack/angular/angular_template
dir=$1
targetdir=$PWD/$dir/public

mkdir $dir &&
cd $dir &&
mkdir public &&
cd public &&
sudo ditto -v $template_dir/* $PWD &&
cd .. &&
npm init -y &&
npm i express &&
npm i mongoose &&
npm i express-session &&
npm i body-parser &&
touch server.js &&
echo "const app = require('./server/config/mongoose.js')
app.listen(8000, () => console.log('listening on port 8000'));
require('./server/config/routes.js')(app);" | tee server.js &&
mkdir server server/config server/controllers server/models &&
touch server/config/mongoose.js &&
echo "const express = require('express');
const app = express();
const session = require('express-session');
const path = require('path');
const bp = require('body-parser');
app.use(express.urlencoded({extended: true}));
app.use(bp.urlencoded({ extended: false }))
app.use(bp.json())
app.use(express.static( path.join(__dirname, './../../public/dist/public')));
console.log(path.join(__dirname,  './../../public/dist/public'));
app.use(session({
    secret: 'thisisakey',
    resave: false,
    saveUninitialized: true,
    cookie: { maxAge: 60000 }
}));
module.exports = app;" | tee server/config/mongoose.js &&
touch server/config/routes.js &&
echo "const placeholders = require('../controllers/placeholders.js');
module.exports = (app) => { }" | tee server/config/routes.js &&
touch server/controllers/placeholders.js &&
echo "const Placeholder = require('../models/placeholder.js')
module.exports = { }" | tee server/controllers/placeholders.js &&
touch server/models/placeholder.js &&
echo "const mongoose = require('mongoose');
mongoose.connect('mongodb://localhost/placeholder', {useNewUrlParser: true});
const PlaceholderSchema = new mongoose.Schema({
    title: { type: String, required: true},
    description: { type: String, default: '', },
}, {timestamps: true });
module.exports = mongoose.model('Placeholder', PlaceholderSchema);" | tee server/models/placeholder.js &&
git init &&
sudo ditto -v $template_dir/.gitignore $PWD &&
osascript -e "tell application \"Terminal\" to do script \"source ~/.profile && cd $targetdir && ng build --watch\"" &&
code .