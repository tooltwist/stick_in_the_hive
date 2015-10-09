#!/bin/sh
#
#	This script is intended to run on top of the standard Digital Ocean image for Docker
#

apt-get update
apt-get install -q -y openjdk-7-jdk
apt-get install -q -y imagemagick
apt-get install -q -y nodejs npm
apt-get install -q -y git git-core
apt-get install -q -y ruby1.9.1

# Install ToolTwist CLI
npm install -g tooltwist

echo ""
echo Install docker-machine
VERSION=v0.4.0
curl -L https://github.com/docker/machine/releases/download/v0.4.0/docker-machine_linux-amd64 > /usr/local/bin/docker-machine
chmod +x /usr/local/bin/docker-machine
docker-machine -v

echo ""
echo "Install docker-compose"
VERSION=v1.4.2
curl -L https://github.com/docker/compose/releases/download/1.4.2/docker-compose-Linux-x86_64  > /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
docker-compose --version


# Create the user to do the builds
adduser --shell /bin/bash build
mkdir /home/build/.ssh
cp /root/.ssh/authorized_keys /home/build/.ssh/
chown build /home/build/.ssh
chmod 600 /home/build/.ssh/authorized_keys
chown build /home/build/.ssh/authorized_keys
chmod 700 /home/build/.ssh

# Make the build login run the build script
echo exec /root/stick_in_the_hive/builder.sh >> ~/.profile
