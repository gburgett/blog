#!/usr/bin/env node

port = 80
if(process.argv.length > 2){
	port = parseInt(process.argv[2])
}

var express = require('express')

var app = express()

	//hide everything in the node folder
app.use('/node', function (req, res, next) {
  res.status(404).sendFile('404.html', {root: process.cwd()});
})

app.use(express.static('.'))


app.use(function(req, res, next) {
  res.status(404).sendFile('404.html', {root: process.cwd()});
});

console.log('listening on port ' + port)
app.listen(port)