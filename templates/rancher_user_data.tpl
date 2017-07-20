#!/bin/bash

exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1

apt-get update

ipv4=$(curl http://169.254.169.254/latest/meta-data/local-ipv4)

wget -qO- https://get.docker.com/ | sh
docker run -d --restart=unless-stopped -p 8080:8080 -p 9345:9345 rancher/server \
     --db-host ${dbHost} --db-port 3306 \
     --db-user ${dbUser} --db-pass ${dbPass} --db-name rancher --advertise-address $ipv4
