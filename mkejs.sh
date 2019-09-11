#!/bin/bash
# A script to create a new MongoDB/Express/Node project, by Michael K

dir=$1

mkdir $dir &&
cd $dir &&
npm init -y &&
npm i express &&
npm i ejs &&
npm i express-session &&
npm i body-parser &&
npm i express-flash &&
npm i mongoose &&
npm i socket.io &&
touch server.js &&
echo "const express = require('express');
const app = express();
const flash = require('express-flash');
const session = require('express-session');
const server = app.listen(8000);
const io = require('socket.io')(server);
const bp = require('body-parser');
const mongoose = require('mongoose');
mongoose.connect('mongodb://localhost/my_db', {useNewUrlParser: true});
/* boilerplate example mongoose schema below. uncomment and edit as desired:
const UserSchema = new mongoose.Schema({
    name: String,
    age: Number
})
// create an object to that contains methods for mongoose to interface with MongoDB
const User = mongoose.model('User', UserSchema);
*/
app.use(express.static(__dirname + '/static'));
app.set('view engine', 'ejs');
app.set('views', __dirname + '/views');
app.use(express.urlencoded({extended: true}));
app.use(bp.urlencoded({ extended: false }))
app.use(bp.json())
app.use(session({
    secret: 'thisisakey',
    resave: false,
    saveUninitialized: true,
    cookie: { maxAge: 60000 }
}));
io.on('connection', (socket) => {
    socket.on('an_action', (data) => {
        console.log(data);
    })
})
app.get('/', (req, res) => {
    res.render('index');
})" | tee server.js &&
mkdir static &&
mkdir static/images &&
mkdir static/stylesheets &&
mkdir views &&
touch views/index.ejs &&
cd views &&
echo "<!DOCTYPE html>
<html lang='en'>
    <head>
        <title>TODO</title>
        <meta charset='utf-8'>
        <meta name='description' content='TODO'>
        <meta name='author' content='Michael Kemper'>
        <meta name='viewport' content='width=device-width, initial-scale=1, shrink-to-fit=no'>
        <link rel='stylesheet' href='https://stackpath.bootstrapcdn.com/bootstrap/4.3.1/css/bootstrap.min.css' integrity='sha384-ggOyR0iXCbMQv3Xipma34MD+dH/1fQ784/j6cY/iJTQUOhcWr7x9JvoRxT2MZw1T' crossorigin='anonymous'>
        <script src='https://ajax.googleapis.com/ajax/libs/jquery/3.4.1/jquery.min.js'></script>
        <script src='https://cdnjs.cloudflare.com/ajax/libs/popper.js/1.14.7/umd/popper.min.js' integrity='sha384-UO2eT0CpHqdSJQ6hJty5KVphtPhzWj9WO1clHTMGa3JDZwrnQq4sF86dIHNDz0W1' crossorigin='anonymous'></script>
        <script src='https://stackpath.bootstrapcdn.com/bootstrap/4.3.1/js/bootstrap.min.js' integrity='sha384-JjSmVgyd0p3pXB1rRibZUAYoIIy6OrQ6VrjIEaFf/nJGzIxFDsf4x0xIM+B07jRM' crossorigin='anonymous'></script>
        <script type='text/javascript' src='/socket.io/socket.io.js'></script>
    </head>
    <body>
        <!-- DIVS GO HERE -->
    </body>
</html>" | tee index.ejs &&
cd .. &&
code .