pokerplanning
=============
To launch the project you first have to create a file named `config.yaml` to setup the hostname and a port to listen to.

On linux systems do:
(In both sub-projects (client/web and server)
`touch config.yaml`

And create the following entries for local development:
```
hostname: localhost
port: whateverYouWant
```

Use whatever port you'd like (e.g.: 4040) and use it on both projects

Then to launch the server, cd into the server directory and type `dart main.dart`

if you want the checked mode type `dart -c main.dart`

The client must be launched with another port number (e.g.: not 4040)
In another terminal you can launch the client with the following command : `pub serve --port=<another port>`

###Notes
Don't forget to `pub get` in each project (client, server) to fetch the necessary packages  
