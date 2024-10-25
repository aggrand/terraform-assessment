#!/bin/bash

apt-get update -y
apt-get install -y netcat

echo "The web server is up! " > index.html
echo "Checking database... " >> index.html

nc -z -w 5 ${db_address} ${db_port} >> index.html 2>&1

nohup busybox httpd -f -p ${server_port} &
