#!/usr/bin/env node

var fs = require('fs');
var url = require('url')

port = 80
if(process.argv.length > 2){
	port = parseInt(process.argv[2])
}
sslport = 443
if(process.argv.length > 3) {
	sslport = parseInt(process.argv[3])
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

	//hide everything in the node folder
app.use('/node', send404)

app.use(express.static('.'))

app.use(send404);