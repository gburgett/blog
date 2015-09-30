#!/usr/bin/env node

var fs = require('fs');
var url = require('url')

dir = "."
if(process.argv.length > 2){
	dir = process.argv[2]
}

port = 80
if(process.argv.length > 3){
	port = parseInt(process.argv[3])
}
sslport = 443
if(process.argv.length > 4) {
	sslport = parseInt(process.argv[4])
}

var express = require('express');
var http = require('http');

var app = express();

console.log("listening on port " + port + " ssl " + sslport)

//http redirect to https
http.createServer(function(request,response){
				urlObj = url.parse(request.url)
				urlObj.protocol = "https:"
				if (request.headers.host) {
					urlObj.host = request.headers.host
				}
				response.writeHead(301, {"Location": url.format(urlObj)});
				response.end();
			}).listen(port)

http.createServer(app).listen(sslport);


function send404(req, res, next) {
	res.status(404).sendFile('404.html', {root: process.cwd()});
}

app.use(express.static(dir))

app.use(send404);