#!/bin/sh
#
#	This script is intended to run on top of the standard Digital Ocean image for Docker
#

echo ""
echo "Updating packages."
echo ""
apt-get update
apt-get install -q -y openjdk-7-jdk
apt-get install -q -y imagemagick
apt-get install -q -y nodejs npm
apt-get install -q -y nodejs-legacy
apt-get install -q -y git git-core
apt-get install -q -y ruby1.9.1
apt-get install -q -y ssmtp mutt

# Install ToolTwist CLI
echo ""
echo "Check tooltwist installation"
npm install -g tooltwist

# Install Grunt
echo ""
echo "Check Grunt installation"
npm install -g grunt-cli

# Install Docker Machine
echo ""
echo Check docker-machine
if which docker-machine ; then
	echo "- already installed"
else
	VERSION=v0.4.0
	URL="https://github.com/docker/machine/releases/download/v0.4.0/docker-machine_linux-amd64"
	curl -L ${URL}  > /usr/local/bin/docker-machine
	chmod +x /usr/local/bin/docker-machine
fi
docker-machine -v

# Install Docker Compose
echo ""
echo "Check Docker Compose"
if which docker-compose ; then
	echo "- already installed"
else
	VERSION=v1.4.2
	URL="https://github.com/docker/compose/releases/download/1.4.2/docker-compose-Linux-x86_64"
	curl -L ${URL}  > /usr/local/bin/docker-machine
	chmod +x /usr/local/bin/docker-compose
fi
docker-compose --version

# Create the user to do the builds
echo "Checking user 'build'"
if [ -d /home/build ] ; then
	echo "- user already exists"
else
	adduser --gid docker --shell /bin/bash build
	mkdir /home/build/.ssh
	cp /root/.ssh/authorized_keys /home/build/.ssh/
	chown build /home/build/.ssh
	chmod 600 /home/build/.ssh/authorized_keys
	chown build /home/build/.ssh/authorized_keys
	chmod 700 /home/build/.ssh

	# Make the build login run the build script
	echo exec /root/stick_in_the_hive/builder.sh >> ~/.profile
fi


# Configure outgoing mail for backups and notifications
# http://www.howtogeek.com/51819/how-to-setup-email-alerts-on-linux-using-gmail/
echo ""
echo ""
echo -n "Enter the email address of a gmail user who will be used to send notifications: "
read SENDER
echo -n "And their password: "
read PASSWORD

# Update the ssmtp config file
sed --in-place "s/^root=postmaster$/root=${SENDER}/" /etc/ssmtp/ssmtp.conf
sed --in-place "s/^mailhub=mail$/mailhub=smtp.gmail.com:587/" /etc/ssmtp/ssmtp.conf
if ! grep BUILDER_CONFIG /etc/ssmtp/ssmtp.conf ; then
	# Add some server-specific config variables
	cat >> /etc/ssmtp/ssmtp.conf << END
# BUILDER_CONFIG
UseSTARTTLS=YES
UseTLS=YES
AuthUser=${SENDER}
AuthPass=${PASSWORD}
FromLineOverride=YES
AuthMethod=LOGIN
END
fi

# Edit the recipients file
if [ ! -r NOTIFY_ADDRESSES ] ; then
	echo '# Enter emails to be sent backups (one per line)' > NOTIFY_ADDRESSES
fi
vi NOTIFY_ADDRESSES

# Open port 5000, for when the designer gets run
iptables -A INPUT -p tcp --dport 5000 -j ACCEPT

# Log in to Docker Hub
echo ""
echo "$ docker login"
docker login
mv ~/.docker/config.json ~build/.docker/config.json
chown build ~build/.docker/config.json

# Create a new key for SSH, to access Github
if [ ! -r ~/.ssh/id_rsa.pub ] ; then
	ssh-keygen -t rsa -b 4096 -C "${SENDER}"

	echo ""
	echo ""
	echo "Please add this SSH Key to Github:"
	echo "(See https://help.github.com/articles/generating-ssh-keys for details)"
	echo ""
	cat /root/.ssh/id_rsa.pub
	mv /root/.ssh/id* ~build/.ssh
	chown build ~build/.ssh/*
	echo ""
	echo ""
	echo "You can check using: ssh -T git@github.com"
	echo ""
fi

