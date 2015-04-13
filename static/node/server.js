#!/usr/bin/env node

var fs = require('fs');
var privateKey = fs.readFileSync(process.env.HOME + '/www.gordonburgett.net_private_key.key');
var certificate = fs.readFileSync(process.env.HOME + '/www.gordonburgett.net_ssl_certificate.cer');
var cacert = fs.readFileSync(process.env.HOME + '/cacert.cer');

port = 80
if(process.argv.length > 2){
	port = parseInt(process.argv[2])
}
sslport = 443
if(process.argv.length > 3) {
	sslport = parseInt(process.argv[3])
}

var express = require('express');
var https = require('https');
var http = require('http');

var app = express();

console.log("listening on port " + port + " ssl " + sslport)

http.createServer(app).listen(port);
https.createServer({key: privateKey, cert: certificate, ca:cacert}, app).listen(sslport);


function send404(req, res, next) {
	res.status(404).sendFile('404.html', {root: process.cwd()});
}

	//hide everything in the node folder
app.use('/node', send404)

app.use(express.static('.'))

app.use(send404);