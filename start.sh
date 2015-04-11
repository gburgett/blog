#! /bin/bash

hugo -w --baseUrl="http://localhost:3000" &
hugo_pid=$!
echo "hugo running with pid $hugo_pid"

trap "kill $hugo_pid; exit" SIGHUP SIGINT SIGTERM EXIT

cd public/

DEBUG=express:* node node/server.js 3000