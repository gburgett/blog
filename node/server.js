#!/usr/bin/env node

var fs = require('fs');
var url = require('url')

dir = "."
if(process.argv.length > 2){
	dir = process.argv[2]
}

sslport = 443
if(process.argv.length > 3){
	sslport = parseInt(process.argv[3])
}

var express = require('express');
var http = require('http');

var app = express();

console.log("listening on port " + sslport)

http.createServer(app).listen(sslport);


function send404(req, res, next) {
	res.status(404).sendFile('404.html', {root: process.cwd()});
}

app.use(express.static(dir))

app.use(send404);