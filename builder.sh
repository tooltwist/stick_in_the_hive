#!/bin/bash
#
#	Script for creating a Docker swarm
#

# Color codes
#http://bitmote.com/index.php?post/2012/11/19/Using-ANSI-Color-Codes-to-Colorize-Your-Bash-Prompt-on-Linux
B="\033[1m"
D="\033[0;37m"
#N="\033[m"
N="\033[0;34m"
BLACK="\033[m"
RED="\033[0;31m"
BLUE="\033[0;34m"
AQUA="\033[0;36m"
GREEN="\033[0;32m"
PURPLE="\033[0;35m"
ORANGE="\033[1;33m"

function defineApp {
	clear
	echo1 ${BLUE}
	echo1 ""
	echo1 Define an application
	echo1 '____________________'
	echo1 ''

	# Get a unique app name
	name=""
	while [ -z "${name}" ] ; do
		echon "${BLUE}App name: ${RED}"
		read name
		echon "${BLUE}"
		if [ -e apps/${name} ] ; then
			echo1 "Name is already used"
			name=""
		fi
	done
	echon "${BLUE}Github path: ${RED}"
	read path
	echon "${BLUE}Branch (master): ${RED}"
	read branch
	[ -z "${branch}" ] && branch="master"
	echon "${BLUE}"

	# Clone the repository as a new app
	echo1 ''
	echo1 "Cloning repository:"
	(
		cd apps
		git clone ${path} ${name}
		echo1 git clone ${path} -b ${branch} ${name}
		rv=$?
		echo1 Exit status is $rv
	)
	echo1 ${N}
}

#
#	Show the containers in the swarm
#
#
function swarmPS {
	swarm=$1
	
	(
		echo1 ${BLUE}
		clear
		echo1 "Containers in Swarm ${swarm}"
		echo1 "____________________________"
		echo1 ""
		echo1 ""
		echo1 '$ eval $(docker-machine env --swarm '${swarm}'-swarm-master)'
		eval $(docker-machine env --swarm ${swarm}-swarm-master)
		env | grep DOCKER
		echo1 ""
		echo1 ${GREEN}
		docker ps
#		docker ps | grep -v jwilder/nginx-proxy
		echo1 ${N}
		echo1 ""
		echo1 ""
		echo1 ""
		echo1 ""
	)
}

#
#	Show the containers in the swarm
#
#
function swarmInfo {
	swarm=$1
	
	(
		echo1 ${BLUE}
		clear
		echo1 "Info for Swarm ${swarm}"
		echo1 "____________________________"
		echo1 ""
		echo -e "${RED}$ eval \"$(docker-machine env --swarm ${swarm}-swarm-master)\"${BLUE}"
		                 eval "(docker-machine env --swarm ${swarm}-swarm-master)"
		env | grep DOCKER
		echo ""
		echo -e "${RED}$ docker info"
		echo -e "${GREEN}"
		        docker info
		echo -e "${N}"
	)
}

#
#	Create an extra swarm mode
#
function addSwarmNode {
	echo1 ""
	echo1 ""
	echo1 ""
	echo1 ""
	echo1 ""
	echo1 Sorry, not adding nodes yet.
	echo1 ""
	echo1 ""
	echo1 ""
	echo1 ""
	echo1 ""
	echo1 ""
	echon "Press Enter to continue: "
	read ans
}



#
#	Initialize tooltwist.js
#
function initCLI {
	app=$1
	echo1 ${BLUE}
	clear
	echo1 'Init ToolTwist CLI in Docker mode'
	echo1 '_________________________________'
	echo1 ''
	
	# Get the repo name
	echo1 '$ git remote -v'
	o=$(git remote -v)
	repo=$(echo1 ${o} | sed 's!origin.\(.*\).(fetch).*!\1!')
	echo1 repo is ${repo}.
	branch=$(git status | grep '^On branch ' | sed 's!On branch !!')
	echo1 branch is ${branch}

	# Initialize tooltwist
	(
		mkdir -p deploy/docker
		echo1 '$ cd deploy/docker'
		cd deploy/docker
		echo1 '$ tooltwist init docker'
		echo1 ${GREEN}
		tooltwist init docker
		echo1 ${BLUE}
		
		# Patch the config file
		sed -i '' 's!"name" : "ttdemo"!"name" : "'${app}'"!' tooltwist.js
		sed -i '' 's!https://github.com/tooltwist/ttdemo.git!'${repo}'!' tooltwist.js
		sed -i '' 's!id: .my-project.,!id: "'${app}'",!' tooltwist.js
	)
	
	#	Create a build script
	createBuildForCLI
	echo1 ${N}
}

#
#	Create a build.sh to start 'tooltwist docker'
#
function createBuildForCLI {
	echo1 'Creating build.sh...'
	echo1 '#!/bin/bash' > deploy/docker/build.sh
	echo1 'tooltwist docker' >> deploy/docker/build.sh
	chmod +x deploy/docker/build.sh
}

#
#	Edit tooltwist.js
#
function editTooltwistJs {
	app=$1
	vi deploy/docker/tooltwist.js
}

#
#	Run the Designer with the Tooltwit CLI
#
function runDesigner {
	app=$1
	echo1 ${BLUE}
	clear
	echo1 'Run ToolTwist Designer'
	echo1 '______________________'
	echo1 ''
	
	# Use the project as it's own webdesign
#	echo1 "$ mkdir -p deploy/docker/.tooltwist/webdesign-projects"
#	mkdir -p deploy/docker/.tooltwist/webdesign-projects
	echo1 "$ rm -f deploy/docker/.tooltwist/webdesign-projects/${app}"
	rm -rf deploy/docker/.tooltwist/webdesign-projects/${app}
#	here=`pwd`
#	echo1 "$ ln -s ${here} deploy/docker/.tooltwist/webdesign-projects/${app}"
#	ln -s ${here} deploy/docker/.tooltwist/webdesign-projects/${app}
	
	# Run the Designer
	(
		echo1 ''
		echo1 "${RED}When you finish, press Ctrl-C${BLUE}"
		echo1 ''

		echo1 '$ cd deploy/docker'
		cd deploy/docker
		echo1 '$ tooltwist designer'
		echo1 "${GREEN}\n"
		trap true SIGINT
		tooltwist designer
		trap - SIGINT
		echo1 "${N}\n"
	)
}

#
#	Build the Docker image
#
function doBuild {
	app=$1
	echo1 ${BLUE}
	clear
	echo1 'Build Docker image'
	echo1 '__________________'
	echo1 ''
	
	# Use the project as it's own webdesign
#	echo1 "$ mkdir -p deploy/docker/.tooltwist/webdesign-projects"
#	mkdir -p deploy/docker/.tooltwist/webdesign-projects
#	echo1 "$ rm -f deploy/docker/.tooltwist/webdesign-projects/${app}"
#	rm -rf deploy/docker/.tooltwist/webdesign-projects/${app}
	
	(
		echo1 '$ cd deploy/docker'
		cd deploy/docker
		echo1 "${RED}cd" `pwd` "${BLUE}"
		trap true SIGINT
		echo1 "${RED}$ eval $(docker-machine env default)${BLUE}"
		        eval $(docker-machine env default)
		env | grep DOCKER

		echo1 "${RED}$ tooltwist -n docker"
		echo1 "${N}"
		tooltwist docker
		trap - SIGINT
		echo1 "${BLUE}\n"
		
		# Display the images we now have
		echo1 "${RED}$ docker images${GREEN}"
		              docker images
		echo1 "${BLUE}"
	)
}

#
#	Start a shell in the application's deploy directory
#
function appDockerDirShell {
	app=$1
	(
		echo1 ''
		echo1 'When you finish, press Ctrl-D'
		echo -e ${BLACK}
		cd deploy/docker
		/bin/bash
		echo -e ${BLUE}
		clear
	)
	
}

#
#	Start a shell in the application's deploy directory
#
function appShell {
	app=$1
	(
		echo1 ''
		echo1 'When you finish, press Ctrl-D'
		echo1 ''
		echo -e ${BLACK}
		/bin/bash
		echoc blue
		echo -e ${BLUE}
		clear
	)
	
}

#
#	Start a shell in the swarm's deploy directory
#
function swarmShell {
	swarm=$1
	(
		echo1 ''
		echo1 'When you finish, press Ctrl-D'
		echo1 ''
		echo -e ${BLACK}
		cd swarms/$swarm
		/bin/bash
		echo -e ${BLUE}
		clear
	)
	
}

#
#	View local image
#
function viewLocalImage {
	app=$1
	echo1 ${GREEN}
	clear
	echo1 'Local Images'
	echo1 '____________'
	echo1 ''
	#docker $(docker-machine config default) images | grep -e 'REPOSITORY' -e "${app}"
	docker images | grep -e 'REPOSITORY' -e "${app}"
	echo1 ${N}
	echo1 ""
	echo1 ""
	echo1 ""
	echo1 ""
}

#
#	View image on Docker Hub
#
function viewDockerHubImage {
	app=$1
	echo1 ${ORANGE}
	clear
	echo1 'Images at Docker Hub'
	echo1 '____________________'
	echo1 ''
	docker $(docker-machine config default) search tooltwist/${app}
	echo1 ${N}
	echo1 ""
	echo1 ""
	echo1 ""
	echo1 ""
}

#
#	Push image to Docker Hub
#
function pushToDockerHub {
	app=$1
	echo1 ${GREEN}
	docker $(docker-machine config default) images | grep -e 'REPOSITORY' -e "${app}"
	echo1 ${N}
	
	# Get the tag
	echon "${BLUE}What tag should be used? ${RED}"
	read tag
	
	if [ -z "${tag}" ] ; then
		echo1 "${RED}No tag provided${BLUE}"
		askEnter
		return
	fi
	echo1 "${BLUE}Will push as tooltwist/${app}"
	
	# Tag the image
	echo1 ""
	echo1 "${RED}$ docker tag ${app}-image tooltwist/${app}:${tag}${GREEN}"
	              docker tag ${app}-image tooltwist/${app}:${tag}			
	
	# Push to Dockerhub		
	echo1 ""
	echo1 "${RED}$ docker push tooltwist/${app}:${tag}${GREEN}"
	              docker push tooltwist/${app}:${tag}
	echo1 "${BLUE}"
}

#
#	Menu for ToolTwist applications
#
function tooltwistAppMenu {
	app=$1
	pwd

	# Check we have a docker directory
	mkdir -p deploy/docker
	
#	# See if we have a build config
#	buildColor=${D}
#	[ -e build/tooltwist.js ] && buildColor=${B}
	
	# See if we have a Compose script
	
	
	while true ; do
		echo1 "${BLUE}"
		echo1 "______________________________________________________"
		echo1 ""
		echo1 "	      TOOLTWIST APPLICATION ${app}"
		echo1 "______________________________________________________"
		echo1 ""


		# Is a ToolTwist project
		mayBuild=N
		mayInitCLI=N
		haveConf=N

		if [ -e deploy/docker/tooltwist.js ] ; then
#			echo1 Found tooltwist.js
			haveConf=Y

			# See if we have a build script
			[ -e deploy/docker/build.sh ] && createBuildForCLI ${app}
			mayBuild=Y
		else
#			echo1 Missing tooltwist.js
			mayInitCLI=Y
		fi
		
		
		cInit=${D}; [ ${mayInitCLI} == 'Y' ] && cInit=${GREEN};
		cEdit=${D}; [ ${haveConf} == 'Y' ] && cEdit=${BLUE};
		cRun=${D}; [ ${haveConf} == 'Y' ] && cRun=${BLUE};
		cBuild=${D}; [ ${mayBuild} == 'Y' ] && cBuild=${BLUE};
		
		
		# Initialise the build with ToolTwist CLI
		echo1 "	Create:"
		echo1 "	  ${cInit}1. Initialise ToolTwist CLI${BLUE}"
		echo1 "	  ${cEdit}2. Edit toolTwist.js${BLUE}"
		echo1 "	  ${cRun}3. Run Designer${BLUE}"
		echo1 "	  ${cBuild}4. Build Docker image${BLUE}"
		echo1 "	  ${BLUE}5. Shell in docker directory${BLUE}"
		echo1 ""


cat << END
	Publish:
	  6. Show image on this machine
	  7. Show image on Docker Hub
	  8. Push image to Docker hub

	Run:
	  10. Map application to a swarm
	  11. Edit docker-compose.yml
	  12. Start application
	  13. Stop application
	  14. Restart application
	  15. Remove application

	  9. View swarm

	  s. Shell
	  f. Finish with this App
END

		echo1 ''
		echon 'Enter selection: '
		read ans
	
		case ${ans} in
		1)
			[ "${mayInitCLI}" == 'Y' ] && initCLI ${app}
			;;
		2)
			vi deploy/docker/tooltwist.js
			[ "$haveConf" == 'Y' ] && editTooltwistJs ${app}
			;;
		3)
			[ "$haveConf" == 'Y' ] && runDesigner ${app}
			;;
		4)
			[ "$mayBuild" == 'Y' ] && doBuild ${app}
			;;
		5)
			appDockerDirShell ${app}
			;;
		6)
			viewLocalImage ${app}
			;;
		7)
			viewDockerHubImage ${app}
			;;
		8)
			pushToDockerHub ${app}
			;;
		s)
			appShell ${app}
			;;
		f)
			return
			;;
		esac
	done
	
}


#
#	Menu for ToolTwist applications
#
function otherAppMenu {
	app=$1
	pwd
	
	# See if we have a build config
	buildColor=${D}
	[ -e build/tooltwist.js ] && buildColor=${B}
	
	# See if we have a Compose script
	
	
	while true ; do
		echo1 "______________________________________________________"
		echo1 ""
		echo1 "	            APPLICATION ${app}"
		echo1 "______________________________________________________"
		echo1 ""

		# See what we're allowed to do.
		mayEdit=N
		mayBuild=N	
		if [ -e deploy/docker/build.sh ] ; then
			mayBuild=Y
			echo1 Have build.sh
		fi
		cEdit=${D}; [ ${mayEdit} == 'Y' ] && cEdit=${B};
		cBuild=${D}; [ ${mayBuild} == 'Y' ] && cBuild=${B};
		
		
		# Initialise the build with ToolTwist CLI
		
echo1 "	Create:"
echo1 "	  ${N}1. Edit build.sh${N}"
echo1 "	  ${cBuild}2. Build Docker image${N}"
echo1 ""


cat << END
	Publish:
	  5. Show image on this machine
	  6. Show image on Docker Hub
	  7. Push image to Docker hub

	Run:
	  9. Edit docker-compose.yml
	  10. Start application
	  11. Stop application

	  s. Shell
	  f. Finish with this App
		
END
	
		echon '	Enter selection: '
		read ans
	
		case ${ans} in
		1)
			mkdir -p deploy/docker
			vi deploy/docker/build.sh
			;;
		2)
			[ ${mayBuild} == 'Y' ] && doBuild
			;;
		5)
			viewLocalImage ${app}
			;;
		6)
			viewDockerHubImage ${app}
			;;
		7)
			pushToDockerHub ${app}
			;;
		s)
			appShell
			;;
		f)
			return
			;;
		esac
	done
	
}

#
#	Maintain Swarms
#
function maintainSwarms {
	
	while true ; do
		echo1 "${BLUE}"
		echo1 "______________________________________________________"
		echo1 ""
		echo1 "	                 MAINTAIN SWARMS"
		echo1 "______________________________________________________"
		echo1 ""

		# Show the existing swarms
		echo1 "${GREEN}"
#		echo1 swarms is ${SWARMS[@]}
		echo1 '	Swarms:'
		for s in "${SWARMS[@]}"; do
			echo1 "	  ${s}"
		done
		echo1 ''
		echo1 "${BLUE}"

		cat << END
	Menu:
	  1. Create a new swarm

	  s. Shell
	  f. Finish with this menu
		
END
	
		echon "	${BLUE}Swarm name or selection: ${RED}"
		read ans
		echon "${N}"
	
		case ${ans} in
		1)
			createSwarm
			;;
		s)
			appShell
			;;
		f)
			return
			;;
		*)
			# Look for an application name			
			cnt=0
			swarm=""
			for n in ${SWARMS[@]} ; do
				if echo1 ${n} | grep "${ans}" ; then
					swarm=${n}
					cnt=`expr $cnt + 1`
				fi
			done
			echo1 ""
			if [ ${cnt} -eq 0 ] ; then
				echo1 "${RED}Swarm ${ans} not found${N}"
				echo1 ""
				echo1 ""
				echon "Press ENTER to continue: "
				return
			elif [ ${cnt} -gt 1 ] ; then
				echo1 "${RED}More than oen swarm matches ${ans}${N}"
				echo1 ""
				echo1 ""
				echon "Press ENTER to continue: "
				return
			fi

			# Work with this swarm
			maintainSingleSwarm ${swarm}
		esac
	done
}

#
#	Create a new swarm
#
function createSwarm {

	# Check we have the required environment
	if [ ! -r DO_ACCESS_TOKEN ] ; then
		echo1 ""
		echo1 "Cannot proceed without a file named DO_ACCESS_TOKEN"
		askEnter
		return
	fi
	
	# Ask for the name of the new swarm
	echon 'Name of swarm: '
	read name
	
	# Check the name is valid
	[ -z ${name} ] && return
	found=N
	for n in ${SWARMS[@]} ; do
		echo1 check $n
		[ ${n} == ${name} ] && found=Y
	done
	if [ ${found} == 'Y' ] ; then
		echo1 'This name is already used'
		return
	fi
	
	(
		# Run the swarm image (only) on the current machine.
		# NOTE: This container is used to register our new
		# swarm with the docker name registry, and to get a
		# tokan that can be used by the swarm nodes to
		# communicate with each other.
		echo1 'Getting a token to identify the swarm...'
		echo1 ''
		echo1 '$ eval $(docker-machine env default)'
		eval $(docker-machine env default)
	
		# Get the new swarm token
		echo1 '$ docker pull swarm'
		docker pull swarm
		
		echo1 '$ docker run --rm swarm create'
		SWARM_TOKEN=$(docker run --rm swarm create)
		if [ $? -ne 0 ] ; then
			echo1 'Could not create swarm token'
			return
		fi
		echo1 ''
		echo1 'New swarm token is' ${SWARM_TOKEN}.
	
		#
		# Create the swarm Master
		#
		DO_ACCESS_TOKEN=`cat DO_ACCESS_TOKEN`
		REGION=sgp1
		SIZE=2gb

		#
		#	Create one worker-only node
		#
		echo1 >&2 "Creating Docker Swarm cluster"
		
		set -x

	  	docker-machine create --driver digitalocean \
	  	    --digitalocean-access-token ${DO_ACCESS_TOKEN} \
	  	    --digitalocean-region ${REGION} \
	  	    --digitalocean-size ${SIZE} \
	  	    --swarm \
	  	    --swarm-master \
	  	    --swarm-discovery token://${SWARM_TOKEN} \
	  	    ${name}-swarm-master
	
		docker-machine create --driver digitalocean \
		    --digitalocean-access-token ${DO_ACCESS_TOKEN} \
		    --digitalocean-region ${REGION} \
		    --digitalocean-size ${SIZE} \
		    --swarm \
		    --swarm-discovery token://${SWARM_TOKEN} \
			--engine-label type=app \
		    ${name}-swarm-01
	
		docker-machine create --driver digitalocean \
		    --digitalocean-access-token ${DO_ACCESS_TOKEN} \
		    --digitalocean-region ${REGION} \
		    --digitalocean-size ${SIZE} \
		    --swarm \
		    --swarm-discovery token://${SWARM_TOKEN} \
			--engine-label type=proxy \
		    ${name}-swarm-proxy
	)
	
	# Now maintain that swarm
	clear
	maintainSingleSwarm ${name}
}


#
#	maintain a single swarm
#
function maintainSingleSwarm {
	swarm=$1
	
	
	(
		echo -e "${RED}$ eval \"$(docker-machine env --swarm ${swarm}-swarm-master)\"${BLUE}"
set -x
		                eval "$(docker-machine env --swarm ${swarm}-swarm-master)"
set +x
	
	
		while true ; do
			echo1 "${BLUE}"
			echo1 "______________________________________________________"
			echo1 ""
			echo1 "	            MAINTAIN SWARM ${swarm}"
			echo1 "______________________________________________________"
			echo1 ""
			
			listApps ${swarm}
			

			cat << END
	Menu:
	  1. Swarm Containers
	  2. Swarm Info
  
	  3. Start proxy
	  4. Stop proxy
	  5. Restart proxy
	  6. View proxy config
	  7. View proxy log
	  
	  8. Start application
	  9. Stop application
	  10. Restart application
	  11. Remove application
  
	  s. Shell
	  f. Finish with this menu
		
END
	
			echon "	${BLUE}Enter selection: ${RED}"
			read ans
			echon "${N}"
	
			case ${ans} in
			1)
				swarmPS ${swarm}
				;;
			2)
				swarmInfo ${swarm}
				;;
			3)
				startProxy ${swarm}
				;;
			4)
				stopProxy ${swarm}
				;;
			5)
				restartProxy ${swarm}
				;;
			6)
				showProxyConfig ${swarm}
				;;
			7)
				followProxyLog ${swarm}
				;;
			8)
				startApp ${swarm} ${ans} 'up -d'
				;;
			9)
				startApp ${swarm} ${ans} stop
				;;
			10)
				startApp ${swarm} ${ans} restart
				;;
			11)
				startApp ${swarm} ${ans} rm
				;;
			s)
				swarmShell ${swarm}
				;;
			f)
				return
				;;
			*)
				echo1 "${RED}Unknown command"
				askEnter
			esac
		done
	)
}


#
#	Start nginx-proxy on the swarm
#
function startProxy {
	swarm=$1
	clear
	echo1 "${BLUE}"
	echo1 ""
	echo1 " Start Proxy for Swarm"
	echo1 "_______________________"
	
	(

		# Set the environment
		echo1 ''
		echo1 "${RED}$ eval \"$(docker-machine env --swarm '${swarm}'-swarm-master)\"${BLUE}"
		eval "$(docker-machine env --swarm ${swarm}-swarm-master)"

		# Copy certificates to the proxy server
		echo1 ""
		echo1 >&2 "Copying TLS config to swarm-proxy"
		echo1 "$ docker-machine scp -r \"$DOCKER_CERT_PATH\" ${swarm}-swarm-proxy:/tmp/docker-certs${BLUE}"
		docker-machine scp -r "$DOCKER_CERT_PATH" ${swarm}-swarm-proxy:/tmp/docker-certs
	
		# Prepare the environment
		echo1 ""
		echo1 >&2 "Prepare environment file for Compose:"
		cat <<EOF | tee proxy.env >&2
DOCKER_TLS_VERIFY=1
DOCKER_HOST=tcp://$(docker-machine ip ${swarm}-swarm-master):3376
DOCKER_CERT_PATH=/tmp/docker-certs
constraint:type==proxy
EOF
		echo1 ""
		
		# Start the nginx container, and limit it to one instance
#		echo1 >&2 "Starting services via Docker Compose"
		echo1 ''
		echo1 "${RED}$ docker-compose -f docker-production-swarm-proxy.yml up -d${BLUE}"
		docker-compose -f docker-production-swarm-proxy.yml up -d
		echo1 ''
		echo1 "${RED}$ docker-compose -f docker-production-swarm-proxy.yml scale proxy=1${BLUE}"
		docker-compose -f docker-production-swarm-proxy.yml scale proxy=1
	)
}


#
#	Stop nginx-proxy on the swarm
#
function stopProxy {
	swarm=$1
	clear
	echo1 "${BLUE}"
	echo1 ""
	echo1 " Stop Proxy for Swarm"
	echo1 "______________________"
	
	(
		# Set the environment
		echo1 ''
		echo1 '$ eval "$(docker-machine env --swarm '${swarm}'-swarm-master)"'
		eval "$(docker-machine env --swarm ${swarm}-swarm-master)"
	
		# Prepare the environment
		echo1 >&2 "Prepare environment file for Compose:"
		cat <<EOF | tee proxy.env >&2
DOCKER_TLS_VERIFY=1
DOCKER_HOST=tcp://$(docker-machine ip ${swarm}-swarm-master):3376
DOCKER_CERT_PATH=/tmp/docker-certs
constraint:type==proxy
EOF
		echo1 ""
		
		# Start the nginx container, and limit it to one instance
		echo1 >&2 "Starting services via Docker Compose"
		echo1 ''
		echo1 '$ docker-compose -f docker-production-swarm-proxy.yml stop'
		docker-compose -f docker-production-swarm-proxy.yml stop
	)
}


#
#	Restart nginx-proxy on the swarm
#
function restartProxy {
	swarm=$1
	clear
	echo1 "${BLUE}"
	echo1 ""
	echo1 " Restart Proxy for Swarm"
	echo1 "_________________________"
	
	(
		# Set the environment
		echo1 ''
		echo1 '$ eval "$(docker-machine env --swarm '${swarm}'-swarm-master)"'
		        eval "$(docker-machine env --swarm "${swarm}"-swarm-master)"
	
		# Prepare the environment
		echo1 >&2 "Prepare environment file for Compose:"
		cat <<EOF | tee proxy.env >&2
DOCKER_TLS_VERIFY=1
DOCKER_HOST=tcp://$(docker-machine ip ${swarm}-swarm-master):3376
DOCKER_CERT_PATH=/tmp/docker-certs
constraint:type==proxy
EOF
		echo1 ""
		
		# Start the nginx container, and limit it to one instance
#		echo1 >&2 "Starting services via Docker Compose"
		echo1 ''
		echo1 '$ docker-compose -f docker-production-swarm-proxy.yml restart'
		        docker-compose -f docker-production-swarm-proxy.yml restart
	)
}

function showProxyConfig {
	swarm=$1

	# Get the proxy container ID
	proxyId=$(docker ps | grep -e "t4-swarm-proxy.*_proxy_1" | sed 's/ .*//')
	if [ -z "${proxyId}" ] ; then
		echo1 ""
		echo1 "${RED}Could not get proxy id. Perhaps it isn't running?${BLUE}"
		echo1 ""
		askEnter
		return
	fi
	echo1 "${BLUE}"
	echo1 "_____________________________________________________________________________${N}"
	echo1 "$ docker exec ${proxyId} /bin/bash -c \"cat /etc/nginx/conf.d/default.conf\""
	        docker exec ${proxyId} /bin/bash -c "cat /etc/nginx/conf.d/default.conf"
	echo1 "${BLUE}"
}

function followProxyLog {
	swarm=$1
	

	# Get the proxy container ID
	proxyId=$(docker ps | grep -e "t4-swarm-proxy.*_proxy_1" | sed 's/ .*//')
	if [ -z "${proxyId}" ] ; then
		echo1 ""
		echo1 "${RED}Could not get proxy id. Perhaps it isn't running?${BLUE}"
		echo1 ""
		askEnter
		return
	fi
	echo1 "Proxy Id is ${proxyId}"
	
	echo1 "${GREEN}Press Ctrl-C when you are finished viewing the logs${N}"
	echo1 ""
	askEnter
	
	trap true SIGINT
	clear
	echo1 "$ docker logs -f ${proxyId}"
	        docker logs -f ${proxyId}
	trap - SIGINT
	echo1 "${BLUE}"
}

function listApps {
	swarm=$1
	
	# List the applications mapped to this swarm
	(
		mkdir -p swarms/${swarm}
		cd swarms/${swarm}
	
		echo1 ""
		echo1 "	Applications for this swarm:"
		echo1 "${GREEN}"
		for n in * ; do
			if [ "${n}" != "*" ] ; then
				[ ${n}/docker-compose.yml ] && echo1 "	  ${n}"
			fi
		done
		echo1 "${BLUE}"
	)
}


#
#	Start nginx-proxy on the swarm
#
function startApp {
	swarm=$1
	app=$2
	op=$3
	clear
	case ${op} in
	start)
		label="Start"
		;;
	stop)
		label="Stop"
		;;
	restart)
		label="Restart"
		;;
	rm)
		label="Remove"
		;;
	esac
	echo1 "${BLUE}"
	echo1 ""
	echo1 " ${label} Application"
	echo1 "____________________"
	
	# Ask the app name
	listApps ${swarm}
	
#	app=askApp
	echo1 ""
	echon "Which application to ${label}? "
	read ans
	
	# Check the application exists
	cnt=0
	for n in swarms/${swarm}/* ; do
		echo1 checking ${n}
		base=`basename ${n}`
		if echo1 ${base} | grep "${ans}" ; then
#			echo1 found
			app=${base}
			cnt=`expr $cnt + 1`
		fi
	done
	echo1 ""
	if [ ${cnt} -eq 0 ] ; then
		echo1 "${RED}App ${ans} not found${N}"
		echo1 ""
		echo1 ""
		echon "Press ENTER to continue: "
		return
	elif [ ${cnt} -gt 1 ] ; then
		echo1 "${RED}More than one app matches ${ans}${N}"
		echo1 ""
		echo1 ""
		echon "Press ENTER to continue: "
		return
	fi
	echo1 "${RED}Will ${label} ${app}${BLUE}"
	
	(
		cd swarms/${swarm}/${app}
		echo1 '$ cd' `pwd`
		
		# Check we have the required files
		if [ ! -r VIRTUAL_HOST -o ! -r VIRTUAL_PORT ] ; then
			echo1 ""
			echo1 "${RED}App ${app} needs to define files VIRTUAL_HOST and VIRTUAL_PORT"
			echo1 "${N}"
			askEnter
			clear
			return
		fi
		VIRTUAL_HOST=`cat VIRTUAL_HOST`
		VIRTUAL_PORT=`cat VIRTUAL_PORT`
		
		if [ ! -f docker-compose.yml ] ; then
			echo1 ""
			echo1 "${RED}App ${app} needs to define docker-compose.yml"
			echo1 "${N}"
			askEnter
			clear
			return
		fi

		# Set the environment for the swarm
		echo1 ''
		echo1 '$ eval "$(docker-machine env --swarm '${swarm}'-swarm-master)"'
		eval "$(docker-machine env --swarm ${swarm}-swarm-master)"

		# Prepare the environment for the application
		echo1 >&2 "Prepare environment file for Compose:"
		cat <<EOF | tee app.env >&2
VIRTUAL_HOST=${VIRTUAL_HOST}
VIRTUAL_PORT=${VIRTUAL_PORT}
constraint:type==app
EOF
		echo1 ""
		
		# Start the nginx container, and limit it to one instance
		echo1 >&2 "Starting services via Docker Compose"
		echo1 ''
		echo1 '$ docker-compose '${op}
		        docker-compose ${op}
		if [ "${op}" == 'start' ] ; then
			echo1 ''
			echo1 '$ docker-compose scale app=1'
			        docker-compose scale app=1
		fi
	)
}


# Get the names of the available swarms
function getSwarmNames {
	mkdir -p swarms
	SWARMS=( `docker-machine ls | grep -e '^\S*-swarm-master ' | sed 's! .*!!' | sed 's!^\(.*\)-swarm-master$!\1!'` )	
}

# Get the application names
function getAppNames {
	mkdir -p apps
	dirs=( apps/* )
	[ ${dirs} == 'apps/*' ] && dirs=()

	APPS=( )
	for d in ${dirs[@]} ; do
		d=`echo $d | sed 's!apps/!!'`
		APPS+=( $d )
	done
}


# Ask the user to select an application
# (beware that all output from this function is considered part of the app name)
function chooseApp {
	echo >&2 -n -e "${BLUE}Application name: ${RED}"
	read ans
	echo >&2 -n -e "${BLUE}"

	app=""
	cnt=0
	for a in ${APPS[@]} ; do
		if echo ${a} | grep "${ans}" > /dev/null 2>&1 ; then
			echo >&2 FOUND $a
			app=${a}
			cnt=`expr ${cnt} + 1`
		fi
	done

	if [ ${cnt} -eq 0 ] ; then
		echo >&2 -e "${RED}No matching app.${BLUE}"
		askEnter
		return 1
	elif [ ${cnt} -eq 1 ] ; then
		echo ${app}
		return 0
	else
		echo >&2 -e "${RED}${cnt} apps match your selection (too many).${BLUE}"
		askEnter
		return 1
	fi
}

function echo1 {
	echo -e "$*"
}

function echon {
	#echo $* \c
	echo -e -n "$*"
}

function echoc {
	color=$1; shift
	case ${color} in
	red)
		echo -e -n "${RED}$*${N}"
		;;
	blue)
		echo -e -n "${BLUE}$*${N}"
		;;
	green)
		echo -e -n "${GREEN}$*${N}"
		;;
	black)
		echo -e -n "${BLACK}$*${N}"
		;;
	aqua)
		echo -e -n "${AQUA}$*${N}"
		;;
	purple)
		echo -e -n "${PURPLE}$*${N}"
		;;
	orange)
		echo -e -n "${ORANGE}$*${N}"
		;;
	esac
}

function askEnter {
	echo >&2 ""
	echo >&2 -e -n "${RED}Press ENTER to continue: ${BLUE}"
	read ans
}


#
#	Start here
#

# Set the environment
#echo1 Checking environment variables to access swarm
#eval $(docker-machine env --swarm swarm-masterz)
clear
echo -e "${RED}Initial environment:"
env | grep DOCKER
echo -n -e "${BLUE}"

getSwarmNames
getAppNames

if [ ! -z ${1} ] ; then
	case ${1} in
	"--swarms" )
		clear
#		echo1 maintain swarms
		maintainSwarms
		exit 0
		;;
	*)
		echo1 "${RED}Unknown parameter: ${1}"
		echo1 "usage: ${0} [--swarms]"
		echo1 "${N}"
		exit 1
		;;
	esac
fi

# Check we have the required directories
mkdir -p apps swarms


# Ok, start by showing the menu
while true ; do
	
	# Show existing applications
	echo1 "______________________________________________________"
	echo1 "                                                      "
	echo1 "                  STICK-IN-THE-HIVE                   "
	echo1 "                                                      "
	echo1 "           (the fastest way to make a swarm)          "
	echo1 "______________________________________________________"
	echo1 ""
	echo1 ""

	# Display the applications and swarms
	printf "  %-30s %s\n" "Applications" "Swarms"
	printf "  %-30s %s\n" "------------" "------"
	echo -e -n "${GREEN}"
	cnt=0
	while true ; do
		app=""; [ ${cnt} -lt ${#APPS[@]} ] && app=${APPS[$cnt]}
		swarm=""; [ ${cnt} -lt ${#SWARMS[@]} ] && swarm=${SWARMS[$cnt]}
		printf "   %-30s %s\n" ${app} ${swarm}
		[ -z "${app}" -a -z "${swarm}" ] && break
		cnt=`expr $cnt + 1`
	done
	echo -e -n "${BLUE}"
	

	# Ask the user what they would like to do
	echo1 ''
	cat << END
Commands:
  1. maintain application
  2. maintain swarm

  4. Maintain swarms.

  5. Define new application.
  6. Define new swarm
  s. Shell
  q. Quit
END

	echo1 ''
	echon 'Selection: '
	read ans

	case "${ans}" in
	1)
		app=$(chooseApp)
		if [ ! -z "${app}" ] ; then
			(
				cd apps/${app}
				clear
				if [ -d navpoints -a -d widgets ] ; then
					tooltwistAppMenu ${app}
				else
					otherAppMenu ${app}
				fi
			)
		fi
		clear
		;;
	5)
		defineApp
		;;
	4)
		maintainSwarms
		;;
#	3)
#		addSwarmNode
#		;;
	s)
		appShell
		;;
	q)
		echo1 Bye.
		exit 0;
		;;
		
	"")
		# Null selection
		echo1 ""
		echo1 "${RED}Hey, you are supposed to enter something!${N}"
		askEnter
		clear
		;;
		
	esac
done
