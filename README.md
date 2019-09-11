Bash scripts designed to automate a few repetitive tasks in Coding Dojo assignments

1. mkang.sh - Creates a boilerplate Angular project, with express, express-session, mongoose, and body-parser imports.
Requires a basic Angular public folder prepared to be copied, along with a target directory specified as part of the command.

Will copy all the Angular imports required, as well as importing other dependencies and modules. Will create modularized boilerplate server folders and files, and immediately opens another terminal window to compile and --watch the angular src folder.

After script completion, server will be ready to run; if you run nodemon server.js you will be able to immediately connect to localhost:8000 and see the Angular splash page.

2. mkejs.sh - Create a very basic mongo/express/node single-file app. Not very useful for most cases but saved me some time.

3. newproject.sh - Create a new Python Django project template, including instantiating a new app (name specified as part of the command string)

4. setupserver.sh - Automates deployment of Java Spring Boot projects, assuming use of an Ubuntu 16.04 server.