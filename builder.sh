#!/bin/bash
#
#	Script for creating a Docker swarm
#
BIN=`dirname $0`

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
		echo -e "Containers in Swarm ${swarm}"
		echo -e "____________________________"
		echo -e ""
		echo -e ""
		echo -e ${RED}'$ eval $(docker-machine env --swarm '${swarm}'-swarm-master)'${GREEN}
		                 eval $(docker-machine env --swarm ${swarm}-swarm-master)
		echo -e ""
		echo -e ${RED}'$ docker ps'${GREEN}
		echo -e ""
		docker ps
		echo -e ${BLUE}
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
		echo -e ${RED}'$ eval "$(docker-machine env --swarm '${swarm}'-swarm-master)"'${BLUE}
		                 eval "$(docker-machine env --swarm ${swarm}-swarm-master)"
		echo ""
		echo -e "${RED}$ docker info"
		echo -e -n "${GREEN}"
		        docker info
		echo -e -n "${BLUE}"
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
	#echo -e '${RED}$ git remote -v${BLUE}'
	o=$(git remote -v)
	repo=$(echo1 ${o} | sed 's!origin.\(.*\).(fetch).*!\1!')
	echo1 "  repo is ${RED}${repo}${BLUE}"
	branch=$(git status | grep '^On branch ' | sed 's!On branch !!')
	echo1 "  branch is ${RED}${branch}${BLUE}"


	# Initialize tooltwist
	(
		mkdir -p deploy/docker
		echo1 '$ cd deploy/docker'
		cd deploy/docker
		echo1 '$ tooltwist init docker'
		echo1 ${GREEN}
		trap true SIGINT
		tooltwist init docker </dev/null
		trap - SIGINT
		echo1 ${BLUE}
		
askEnter
		# Patch the config file
		sed --in-place 's!"name" : "ttdemo"!"name" : "'${app}'"!' tooltwist.js
		sed --in-place 's!https://github.com/tooltwist/ttdemo.git!'${repo}'!' tooltwist.js
		sed --in-place 's!id: .my-project.,!id: "'${app}'",!' tooltwist.js
	)
	
askEnter
	#	Create a build script
	createBuildForCLI
	echo1 ${N}
askEnter
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
		tooltwist designer < /dev/null
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
		echo1 "$ cd ${HOME}/apps/${app}/deploy/docker"
		         cd ${HOME}/apps/${app}/deploy/docker

		trap true SIGINT
		echo1 "${RED}$ tooltwist -n docker${BLACK}"
		               tooltwist docker < /dev/null
		echo1 "${BLUE}\n"
		trap - SIGINT
		
		# Display the images we now have
		echo1 "${RED}$ docker images${GREEN}"
		              docker images
		echo1 "${BLUE}"
	)
}

#
#	Flush the files from a previous ToolTwist build
#
function flushBuild {
	echo -e ${RED}"$ rm -rf ${HOME}/apps/${app}/deploy/docker/.tooltwist"${GREEN}
			         rm -rf ${HOME}/apps/${app}/deploy/docker/.tooltwist
	askEnter
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
	echo -e "${RED}docker images | grep -e REPOSITORY -e \"${app}\"${GREEN}"
	               docker images | grep -e REPOSITORY -e "${app}"
	echo -e ${BLUE}
	
	# Get the tag
	echon "${BLUE}What tag should be used? ${RED}"
	read tag
	
	if [ -z "${tag}" ] ; then
		echo1 "${RED}No tag provided${BLUE}"
		askEnter
		return
	fi
	echo1 "${BLUE}Will push as tooltwist/${app}:${tag}"
	
	# Tag the image
	echo1 ""
	echo1 "${RED}$ docker tag -f ${app}-image tooltwist/${app}:${tag}${GREEN}"
	              docker tag -f ${app}-image tooltwist/${app}:${tag}			
	
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
		echo1 "	  ${cBuild}5. Flush previous build${BLUE}"
		echo1 "	  ${BLUE}6. Shell in docker directory${BLUE}"
		echo1 ""


cat << END
	Publish:
	  7. Show image on this machine
	  8. Show image on Docker Hub
	  9. Push image to Docker hub

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
			#vi deploy/docker/tooltwist.js
			[ "$haveConf" == 'Y' ] && editTooltwistJs ${app}
			;;
		3)
			[ "$haveConf" == 'Y' ] && runDesigner ${app}
			;;
		4)
			[ "$mayBuild" == 'Y' ] && doBuild ${app}
			;;
		5)
			[ "$mayBuild" == 'Y' ] && flushBuild ${app}
			;;
		6)
			appDockerDirShell ${app}
			;;
		7)
			viewLocalImage ${app}
			;;
		8)
			viewDockerHubImage ${app}
			;;
		9)
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
	
	# Loop around, allowing menu selections
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
	doTokenFile=${BIN}/DO_ACCESS_TOKEN
	if [ ! -r ${doTokenFile} ] ; then
		echo -e ""
		echo -e "${RED}Cannot proceed without ${doTokenFile}.${BLUE}"
		echo -e "This file should contain your DigitalOcean access token"
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
		[ ${n} == ${name} ] && found=Y
	done
	if [ ${found} == 'Y' ] ; then
		echo -e 'This name is already used'
		askEnter
		return
	fi
	
	(

		# Run the swarm image (only) on the current machine.
		# NOTE: This container is used to register our new
		# swarm with the docker name registry, and to get a
		# tokan that can be used by the swarm nodes to
		# communicate with each other.
		echo -e 'Getting a token to identify the swarm...'
		echo -e ''
	
		# Get the new swarm token
		echo -e "${RED}$ docker pull swarm${GREEN}"
		docker pull swarm
		
		echo -e "${RED}$ docker run --rm swarm create${GREEN}"
		SWARM_TOKEN=$(docker run --rm swarm create)
		if [ $? -ne 0 ] ; then
			echo -e "${RED}Could not create swarm token${BLUE}"
			return
		fi
		echo -e ''
		echo -e "${BLUE}New swarm token is ${SWARM_TOKEN}"
	
		#
		# Create the swarm Master
		#
		echo "Loading DigitalOcean access token from ${doTokenFile}"
		DO_ACCESS_TOKEN=$(cat ${doTokenFile})
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
	askEnter
	clear
	maintainSingleSwarm ${name}
}


#
#	maintain a single swarm
#
function maintainSingleSwarm {
	swarm=$1

	# Optional file to contain a "message of the day"
	msgFile=${HOME}/swarms/${swarm}/MOTD

	# Loop around, allowing menu selections
	clear
	(
		echo -e ${RED}'$ eval "$(docker-machine env --swarm '${swarm}'-swarm-master)"'${BLUE}
		                eval "$(docker-machine env --swarm ${swarm}-swarm-master)"
	
		while true ; do
			echo1 "${BLUE}"
			echo1 "______________________________________________________"
			echo1 ""
			echo1 "	            MAINTAIN SWARM ${swarm}"
			if [ -r ${msgFile} ] ; then
				echo -e -n "${PURPLE}"
				cat ${msgFile}
				echo -e -n "${BLUE}"
			fi
			echo1 "______________________________________________________"
			echo1 ""
			
			listApps ${swarm}
			

			cat << END
	Menu:
	  1. Swarm Containers
	  2. Swarm Info
	  3. Login to app container
	  
	  4. Map application to this swarm

	  Application
	  11. Tail log
	  12. Pull from Docker Hub and Start
	  13. Temporarily Stop
	  14. Start again

	  16. Edit docker-compose.yml
	  17. Shell in config directory
  
	  Proxy
	  91. Tail log
	  92. Pull and Start proxy
	  93. Stop proxy
	  94. Start proxy again
	  95. Remove proxy container
	  96. View proxy config
	  97. Login to proxy container
  
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
				loginAppContainer ${swarm}
				;;

			# App definitions
			4)
				mapAppToSwarm ${swarm}
				;;

			# Application
			11)
				applicationOp ${swarm} logs
				;;
			12)
				applicationOp ${swarm} start
				;;
			13)
				applicationOp ${swarm} stop
				;;
			14)
				applicationOp ${swarm} restart
				;;
#			15)
#				applicationOp ${swarm} rm
#				;;
			16)
				applicationOp ${swarm} composeYml
				;;
			17)
				applicationOp ${swarm} shell
				;;

			# Proxy
			91)
				followProxyLog ${swarm}
				;;
			92)
				proxyOp ${swarm} "Pull and Start"
				;;
			93)
				proxyOp ${swarm} Stop
				;;
			94)
				proxyOp ${swarm} Restart
				;;
#			95)
#				proxyOp ${swarm} Remove
#				;;
			96)
				showProxyConfig ${swarm}
				;;
			97)
				proxyOp ${swarm} Shell
				;;

			s)
				swarmShell ${swarm}
				;;
			f)
				return
				;;
			*)
				echo1 "${RED}	Unknown command"
				askEnter
				clear
				;;
			esac
		done
	)
}


#
#	Start nginx-proxy on the swarm
#
function proxyOp {
	swarm=$1
	op=$2

	clear
	echo1 "${BLUE}"
	echo1 ""
	echo1 " ${op} proxy for Swarm"
	echo1 "__________________________________________________"
	
	(

		# Set the environment
		echo ''
		echo -e ${RED}'$ eval "$(docker-machine env --swarm '${swarm}'-swarm-master)"'${BLUE}
		                 eval "$(docker-machine env --swarm ${swarm}-swarm-master)"

		# Perhaps copy certificates to the proxy server
		if [ "${op}" == "Pull and Start" ] ; then
			echo -e ""
			echo -e "Copying TLS config to swarm-proxy"
			echo -e ${RED}'$ docker-machine scp -r "$DOCKER_CERT_PATH" '${swarm}'-swarm-proxy/:/tmp/docker-certs'${GREEN}
			              docker-machine scp -r "$DOCKER_CERT_PATH" ${swarm}-swarm-proxy/:/tmp/docker-certs/
			echo -e -n ${BLUE}
		fi
	
		# Prepare the environment
		echo -e ""
		echo -e ${RED}'Environment file for Compose:'${BLUE}
		cat <<EOF | tee proxy.env >&2
DOCKER_TLS_VERIFY=1
DOCKER_HOST=tcp://$(docker-machine ip ${swarm}-swarm-master):3376
DOCKER_CERT_PATH=/tmp/docker-certs
constraint:type==proxy
EOF
		echo ""

echo OP IS ${op}.

	# Check the operation
	case ${op} in
	"Pull and Start")
		# Start/Stop/Restart/Remove the nginx container
		echo -e ''
		echo -e ${RED}"$ docker-compose -f ${BIN}/docker-production-swarm-proxy.yml rm"${GREEN}
		                 docker-compose -f ${BIN}/docker-production-swarm-proxy.yml rm
		echo -e ${RED}"$ docker-compose -f ${BIN}/docker-production-swarm-proxy.yml pull"${GREEN}
		                 docker-compose -f ${BIN}/docker-production-swarm-proxy.yml pull
		echo -e ${RED}"$ docker-compose -f ${BIN}/docker-production-swarm-proxy.yml up -d"${GREEN}
		                 docker-compose -f ${BIN}/docker-production-swarm-proxy.yml up -d
		echo -e -n ${BLUE}
		;;
	Stop)
		# Start/Stop/Restart/Remove the nginx container
		echo -e ''
		echo -e ${RED}"$ docker-compose -f ${BIN}/docker-production-swarm-proxy.yml stop"${GREEN}
		                 docker-compose -f ${BIN}/docker-production-swarm-proxy.yml stop
		echo -e -n ${BLUE}
		;;
	Restart)
		# Start/Stop/Restart/Remove the nginx container
		echo -e ''
		# Note we use start, not restart
		echo -e ${RED}"$ docker-compose -f ${BIN}/docker-production-swarm-proxy.yml start"${GREEN}
		                 docker-compose -f ${BIN}/docker-production-swarm-proxy.yml start
		echo -e -n ${BLUE}
		;;

#	Remove)
#		cmd="rm"
#		;;

	Shell)
		container=$(docker ps | grep "${swarm}-swarm-proxy/stickinthehive_proxy_1" | sed 's!\s.*!!')
		if [ ! -z ${container} ] ; then
			trap true SIGINT
			echo -e "${RED}$ docker exec -it ${container} /bin/bash${PURPLE}"
					   docker exec -it ${container} /bin/bash
			trap - SIGINT
			echo -e -n "${BLUE}"
		fi
		return
		;;
	*)
		echo "Unknown proxy operation ${op}."
		askEnter
		;;
	esac


return
#ZZZZZ
		# Start/Stop/Restart/Remove the nginx container
		echo -e ''
		echo -e ${RED}'$ docker-compose -f '${BIN}'/docker-production-swarm-proxy.yml '${cmd}${GREEN}
		                 docker-compose -f ${BIN}/docker-production-swarm-proxy.yml ${cmd}
		echo -e -n ${BLUE}

		# If starting, constrain the proxy to just one container
		if [ "${op}" == "Start" ] ; then
			echo -e ''
			echo -e ${RED}'$ docker-compose -f '${BIN}'/docker-production-swarm-proxy.yml scale proxy=1'${GREEN}
						   docker-compose -f ${BIN}/docker-production-swarm-proxy.yml scale proxy=1
			echo -e -n ${BLUE}
		fi
	)
}

#
#	Send a backup by email
function emailBackup {
	clear
	echo -e -n "${BLACK}"
	${BIN}/sendBackupEmail.sh
	echo -e -n "${BLUE}"
	askEnter
	clear
}



##
##	Stop nginx-proxy on the swarm
##
#function stopProxy {
#	swarm=$1
#	clear
#	echo1 "${BLUE}"
#	echo1 ""
#	echo1 " Stop Proxy for Swarm"
#	echo1 "______________________"
#	
#	(
#		# Set the environment
#		echo ''
#		echo -e ${RED}'$ eval "$(docker-machine env --swarm '${swarm}'-swarm-master)"'${GREEN}
#		eval "$(docker-machine env --swarm ${swarm}-swarm-master)"
#	
#		# Prepare the environment
#		echo ""
#		echo -e "${BLUE}Environment file for Compose:"
#		cat <<EOF | tee proxy.env >&2
#DOCKER_TLS_VERIFY=1
#DOCKER_HOST=tcp://$(docker-machine ip ${swarm}-swarm-master):3376
#DOCKER_CERT_PATH=/tmp/docker-certs
#constraint:type==proxy
#EOF
#		echo ""
#		
#		# Start the nginx container, and limit it to one instance
#		echo -e ${RED}'$ docker-compose -f docker-production-swarm-proxy.yml stop'${BLUE}
#		                 docker-compose -f docker-production-swarm-proxy.yml stop
#	)
#}
#
#
##
##	Restart nginx-proxy on the swarm
##
#function restartProxy {
#	swarm=$1
#	clear
#	echo1 "${BLUE}"
#	echo1 ""
#	echo1 " Restart Proxy for Swarm"
#	echo1 "_________________________"
#	
#	(
#		# Set the environment
#		echo1 ''
#		echo1 '$ eval "$(docker-machine env --swarm '${swarm}'-swarm-master)"'
#		        eval "$(docker-machine env --swarm "${swarm}"-swarm-master)"
#	
#		# Prepare the environment
#		echo1 >&2 "Prepare environment file for Compose:"
#		cat <<EOF | tee proxy.env >&2
#DOCKER_TLS_VERIFY=1
#DOCKER_HOST=tcp://$(docker-machine ip ${swarm}-swarm-master):3376
#DOCKER_CERT_PATH=/tmp/docker-certs
#constraint:type==proxy
#EOF
#		echo1 ""
#		
#		# Start the nginx container, and limit it to one instance
##		echo1 >&2 "Starting services via Docker Compose"
#		echo1 ''
#		echo1 '$ docker-compose -f docker-production-swarm-proxy.yml restart'
#		        docker-compose -f docker-production-swarm-proxy.yml restart
#	)
#}

function showProxyConfig {
	swarm=$1

	# Get the proxy container ID
	proxyId=$(docker ps | grep -e "${swarm}-swarm-proxy.*_proxy_1" | sed 's/ .*//')
	if [ -z "${proxyId}" ] ; then
		echo -e ""
		echo -e "${RED}Could not get proxy id. Perhaps it isn't running?${BLUE}"
		echo -e ""
		askEnter
		return
	fi
	echo -e "${BLUE}"
	echo -e "_____________________________________________________________________________${N}"
	echo -e ${RED}'$ docker exec '${proxyId}' /bin/bash -c "cat /etc/nginx/conf.d/default.conf"'${GREEN}
	                 docker exec ${proxyId} /bin/bash -c "cat /etc/nginx/conf.d/default.conf"
	echo -e -n "${BLUE}"
}

function followProxyLog {
	swarm=$1
	

	# Get the proxy container ID
	proxyId=$(docker ps | grep -e "${swarm}-swarm-proxy.*_proxy_1" | sed 's/ .*//')
	if [ -z "${proxyId}" ] ; then
		echo -e ""
		echo -e "${RED}Could not get proxy id. Perhaps it isn't running?${BLUE}"
		echo -e ""
		askEnter
		return
	fi
	
	echo -e ""
	echo -e ""
	echo -e ""
	echo -e "${GREEN}Press Ctrl-C when you are finished viewing the logs"
	echo -e ""
	askEnter
	
	clear
	trap true SIGINT
	echo -e "$ docker logs -f ${proxyId}"
	        docker logs -f ${proxyId}
	trap - SIGINT
	echo -e -n "${BLUE}"
}

function listApps {
	swarm=$1
	
	# List the applications mapped to this swarm
	(
		mkdir -p swarms/${swarm}
		cd swarms/${swarm}
	
		echo -e ""
		getAppsMappedToSwarm ${swarm}
		echo -e -n "${BLUE}"
		printf "	%-15s %-15s\n" "Application" "Domain"
		echo -e -n "${GREEN}"
		for mapped in ${APPS_FOR_SWARM[@]} ; do
			msg1=""; [ -r ${mapped}/VIRTUAL_HOST ] && msg1=`cat ${mapped}/VIRTUAL_HOST`
			msg2=""; [ ! -r ${mapped}/docker-compose.yml ] && msg2="(missing docker-compose.yml)"
			printf "	%-15s %-15s %s\n" "${mapped}" "${msg1}" "${msg2}"
		done
		echo1 "${BLUE}"
	)
}

function mapAppToSwarm {
	swarm=$1

	echo ""
	echo "Available Apps:"
	echo ""
	getAppsMappedToSwarm ${swarm}
	available=( )
	for app in ${APPS[@]} ; do
		found=N
		for mapped in ${APPS_FOR_SWARM[@]} ; do
			[ ${mapped} = ${app} ] && found=Y
		done

		if [ ${found} = 'N' ] ; then
			echo -e -n ${GREEN}
			printf "  %s\n" ${app}
			available+=( ${app} )
		else
			echo -e -n ${RED}
			printf "  %-20s %s\n" ${app} "(already mapped)"
		fi
	done

	echo -e ""
	echo -e -n "${BLUE}Which app would you like to map to swarm ${swarm}? ${RED}"
	read ans

	cnt=0
	for a in ${available[@]} ; do
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
	elif [ ${cnt} -gt 1 ] ; then
		echo >&2 -e "${RED}${cnt} apps match your selection (too many).${BLUE}"
		askEnter
		return 1
	fi

#echo "App is ${app}"
#	ls -l ${HOME}/apps/${app}

	getDeploymentModesForApp ${app}

	#echo MODES is ${DEPLOYMENT_MODES[@]}
	if [ ${#DEPLOYMENT_MODES[@]} -eq 0 ] ; then

		# Perhaps create a default deployment mode
		echo -e -n "App ${app} does not define any deployment modes. Create one [y/N]? "
		read ans
		if [ "${ans}" = "y" ] ; then

			# Ask for details
			echo -e -n "Mode name? "
			read mode
			[ ${mode} = "docker" ] && return
			echo -e -n "Hostname? "
			read HOSTNAME
			echo -e -n "Port [8080]? "
			read PORT
			[ -z "${PORT}" ] && PORT=8080


			# Create a default docker-compose.yml
			mkdir -p "${HOME}/apps/${app}/deploy/${mode}"
			ymlFile=${HOME}/apps/${app}/deploy/${mode}/docker-compose.yml
			cat > ${ymlFile} << END
app:
  #build: .
  image: tooltwist/${app}
  ports:
    - ":8080"
  env_file:
    - app.env
END
			echo ${HOSTNAME} > ${HOME}/apps/${app}/deploy/${mode}/VIRTUAL_HOST
			echo ${PORT} > ${HOME}/apps/${app}/deploy/${mode}/VIRTUAL_PORT
		else
			# Don't create a default
			return
		fi

	else

		# Choose a deployment mode
		ready=N
		echo "Available modes:"
		while [ ${ready} = N ] ; do
			for mode in ${DEPLOYMENT_MODES} ; do
				echo "	  ${mode}"
			done
			echo -e -n "Mode: "
			read ans
			[ -z ${ans} ] && return

			cnt=1
			for m in ${DEPLOYMENT_MODES} ; do
				if echo "#{m}" | grep -e "${ans}" ; then
					mode=${m}
					cnt=`expr ${cnt} + 1`
				fi
			done
			if [ ${cnt} -lt 1 ] ; then
				echo "No mode found"
			elif [ ${cnt} -gt 1 ] ; then
				echo "${cnt} modes match (too many)"
			else
				ready=Y
			fi
		done
	fi

	# Copy the mode to the swarm
	modeDir=${HOME}/apps/${app}/deploy/${mode}
	swarmDir=${HOME}/swarms/${swarm}/${app}
	#echo -e "${RED}$ mkdir -p ${swarmDir}${BLUE}"
	#                 mkdir -p ${swarmDir}
	#echo -e "${RED}$ cp ${modeDir}/* ${swarmDir}${BLUE}"
	#                 cp ${modeDir}/* ${swarmDir}
	echo -e "${RED}ln -s ${modeDir} ${swarmDir}${BLUE}"
		           ln -s ${modeDir} ${swarmDir}

}

#
#	Start nginx-proxy on the swarm
#
function applicationOp {
	echo "applicationOp($1, $2)"
	swarm=$1
	op=$2

	clear
	case ${op} in
	start)
		label="Start"
		cmd="up -d"
		;;
	stop)
		label="Stop"
		cmd="start"
		;;
	restart)
		label="Restart"
		cmd="start"
		;;
	rm)
		label="Remove"
		cmd="rm"
		;;
	composeYml)
		label="Edit docker-compose.yml for"
		;;
	logs)
		label="View log for"
		cmd="logs"
		;;
	shell)
		label="Shell in config directory of"
		;;
	login)
		label="Login to container of"
		;;
	esac
	echo1 "${BLUE}"
	echo1 ""
	echo1 " ${label} application on swarm ${swarm}"
	echo1 "__________________________________________________"
	
	# Ask the app name
	#listApps ${swarm}
	getAppsMappedToSwarm $swarm
	echo -e "Mapped applications:"
	echo -e ""
	for app in ${APPS_FOR_SWARM[@]} ; do
		echo -e "  ${GREEN}${app}${BLUE}"
	done
	
#	app=askApp
	echo -e ""
	echo -e -n "Which application to ${label}? ${RED}"
	read ans
	echo -e -n "${BLUE}"
	[ -z "${ans}" ] && return
	
	# Check the application exists
	cnt=0
	for a in ${APPS_FOR_SWARM[@]} ; do
		if echo1 ${a} | grep "${ans}" ; then
			app=${a}
			cnt=`expr $cnt + 1`
		fi
	done
	echo1 ""
	if [ ${cnt} -eq 0 ] ; then
		echo1 "${RED}App ${ans} not found${BLUE}"
		echo1 ""
		echo1 ""
		echon "Press ENTER to continue: "
		return
	elif [ ${cnt} -gt 1 ] ; then
		echo1 "${RED}More than one app matches ${ans}${BLUE}"
		echo1 ""
		echo1 ""
		echon "Press ENTER to continue: "
		return
	fi
	echo1 "${BLUE}${label} ${app}${BLUE}"
	
	# Maybe edit the config file
	if [ "${op}" = "composeYml" ] ; then
		vi ${HOME}/swarms/${swarm}/${app}/docker-compose.yml
		clear
		return
	elif [ "${op}" = "shell" ] ; then
		(
			cd ${HOME}/swarms/${swarm}/${app}
			trap true SIGINT
			echo -e -n ${BLACK}
			/bin/bash
			echo -e -n ${BLUE}
			trap - SIGINT
		)
		return
	fi

	# Perform a docker operation of the application
	(
		echo -e "${RED}$ cd ${HOME}/swarms/${swarm}/${app}${BLUE}"
		                 cd ${HOME}/swarms/${swarm}/${app}
		ls -l
		
		# Check we have the required files
		if [ ! -r VIRTUAL_HOST -o ! -r VIRTUAL_PORT ] ; then
			echo1 ""
			echo1 "${RED}App ${app} needs to define files VIRTUAL_HOST and VIRTUAL_PORT${BLUE}"
			askEnter
			clear
			return
		fi
		VIRTUAL_HOST=`cat VIRTUAL_HOST`
		VIRTUAL_PORT=`cat VIRTUAL_PORT`
		
		if [ ! -r "docker-compose.yml" ] ; then
			echo -e ""
			echo -e "${RED}Application ${app} needs to define docker-compose.yml${BLUE}"
			askEnter
			clear
			return
		fi

		# Set the environment for the swarm
		echo -e ''
		echo -e ${RED}'$ eval "$(docker-machine env --swarm '${swarm}'-swarm-master)"'${BLUE}
		                 eval "$(docker-machine env --swarm ${swarm}-swarm-master)"

		# Prepare the environment for the application
		echo -e ""
		echo -e >&2 "Prepare environment file for Compose:"
		cat <<EOF | tee app.env >&2
VIRTUAL_HOST=${VIRTUAL_HOST}
VIRTUAL_PORT=${VIRTUAL_PORT}
constraint:type==app
EOF
		echo1 ""





		case ${op} in
		start)
			label="Start"
			# Perform the docker-compose operation
			echo -e ''
			echo -e ${RED}"$ docker-compose stop"${GREEN}
					         docker-compose stop
			echo ""
			echo -e ${RED}"$ docker-compose rm"${GREEN}
					         docker-compose rm
			echo -e ${RED}"$ docker-compose pull"${GREEN}
					         docker-compose pull
			echo ""
			echo -e ${RED}"$ docker-compose up -d"${GREEN}
					         docker-compose up -d

			# Limit the number of instances, if starting
			echo -e ''
			echo -e ${RED}"$ docker-compose scale app=1"${BLUE}
					         docker-compose scale app=1
			;;

		stop)
			label="Stop"
			echo -e ''
			echo -e ${RED}"$ docker-compose stop"${BLUE}
					         docker-compose ${op}
			;;

		restart)
			label="Restart"
			echo -e ''
			# Note we use start, not restart
			echo -e ${RED}"$ docker-compose start"${BLUE}
					         docker-compose start
			;;

		composeYml)
			label="Edit docker-compose.yml for"
			echo -e ''
			echo -e ${RED}'$ docker-compose '${op}${BLUE}
					         docker-compose ${op}
			;;

		logs)
			label="View log for"
			cmd="logs"
			echo -e ''
			echo -e ${RED}'$ docker-compose '${op}${BLUE}
					         docker-compose ${op}
			;;

		shell)
			label="Shell in config directory of"
			echo -e ''
			echo -e ${RED}'$ docker-compose '${op}${BLUE}
					         docker-compose ${op}
			;;

		login)
			label="Login to container of"
			echo -e ''
			echo -e ${RED}'$ docker-compose '${op}${BLUE}
					         docker-compose ${op}
			;;
		esac
	)
}

# Display a list of containers for the current swarm
# - also sets a variable named CONTAINER_IDS
# - all output is send to stdout
function showContainers {
	CONTAINER_IDS=( )
	printf "%3s %-15s %-25s %-15s %s\n" "" "CONTAINER ID" "IMAGE" "STATUS" "NAME" >&2
	# Read one line at a time
	cnt=1
	IFS=$'\n'
	lines=( $(docker ps --format "{{.ID}}:{{.Image}}:{{.Status}}" ) )

	for l in ${lines[@]} ; do

		# Split into separate fields
		IFS=':' read -a flds <<< "$l"
		id=${flds[0]}
		image=${flds[1]}
		uptime=${flds[2]}

		# Get the name of the container
		name=`docker inspect --format="{{.Node.Name}}{{.Name}}" ${id}`

		# Display the container and add to the list
		printf "%-3d %-15s %-25s %-15s %s\n" "${cnt}" "${id}" "${image}" "${uptime}" "${name}" >&2
		CONTAINER_IDS+=( "${id}" )
		cnt=`expr ${cnt} + 1`
	done
	unset IFS
}

# Choose a container
# Note that all output is interpreted as the containerId
function chooseContainer {

	# Show a list of containers
	showContainers
	numContainers=${#CONTAINER_IDS[@]}

	echo "" >&2
	echo -e -n "${BLUE}Container: ${RED}" >&2
	read ans
	echo -e -n "${BLUE}" >&2

	# Check an integer was entered
	if [ "$ans" -eq "$ans" ] 2>/dev/null ; then
		num=`expr ${ans} - 1`

		if [ "${num}" -lt 0 -o "${num}" -ge "${numContainers}" ] ; then
			echo -e "${RED}Incorrect selection." >&2
			askEnter >&2
		else
			id=${CONTAINER_IDS[${num}]}
			echo ${id}
		fi
	else
		echo -e -n "Invalid selection." >&2
		askEnter >&2
		return
	fi
}


# Login to a container within an app, within a swarm
function loginAppContainer {
	swarm=$1

	clear
	echo1 ${BLUE}
	echo1 ""
	echo1 Login to Container
	echo1 '_________________'
	echo1 ''

	# Ask for a container ID
	id=$( chooseContainer ${swarm} )
	[ -z "${id}" ] && return

	# Run the docker exec command
	trap true SIGINT
	echo -e ${RED}"$ docker exec -it ${id} /bin/bash"${BLACK}
	echo ""
	echo ""
	                 docker exec -it ${id} /bin/bash
	echo -e ${BLUE}
	trap - SIGINT
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

# Find the applications mapped to this swarm
function getAppsMappedToSwarm {
	swarm=$1
	APPS_FOR_SWARM=( )
	for n in ${HOME}/swarms/${swarm}/* ; do
		if [ -d "${n}" ] ; then
			dir=`basename ${n}`
			if [ "${dir}" != "*" ] ; then
				APPS_FOR_SWARM+=( ${dir} )
			fi
		fi
	done
}

# Find the deployment modes for an application
function getDeploymentModesForApp {
	app=$1

	DEPLOYMENT_MODES=( )
	mkdir -p ${HOME}/apps/${app}/deploy
	for n in ${HOME}/apps/${app}/deploy/* ; do
		echo looking at ${n}
		dir=`basename ${n}`
		[ "${dir}" != '*' -a "${dir}" != 'docker' ] && DEPLOYMENT_MODES+=( ${dir} )
	done
	#echo modes is ${DEPLOYMENT_MODES[@]}
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

# Ask the user to select a swarm
# (beware that all output from this function is considered part of the swarm name)
function chooseSwarm {

	# If there is only one swarm, use it
	if [ ${#SWARMS[@]} -eq 1 ] ; then
		echo ${SWARMS[0]}
		return
	fi

	# Ask the swarm name
	echo >&2 -n -e "${BLUE}Swarm name: ${RED}"
	read ans
	echo >&2 -n -e "${BLUE}"

	app=""
	cnt=0
	for a in ${SWARMS[@]} ; do
		if echo ${a} | grep "${ans}" > /dev/null 2>&1 ; then
			echo >&2 FOUND $a
			app=${a}
			cnt=`expr ${cnt} + 1`
		fi
	done

	if [ ${cnt} -eq 0 ] ; then
		echo >&2 -e "${RED}No matching swarm${BLUE}"
		askEnter
		return 1
	elif [ ${cnt} -eq 1 ] ; then
		echo ${app}
		return 0
	else
		echo >&2 -e "${RED}${cnt} swarms match your selection (too many).${BLUE}"
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
HOME=`pwd`

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
	if [ -r MOTD ] ; then
		echo -e -n ${PURPLE}
		cat MOTD
		echo -e -n ${BLUE}
	fi
	echo1 "______________________________________________________"
	echo1 ""
	echo1 ""

	# Display the applications and swarms
	getAppNames
	printf "  %-30s %s\n" "Swarms" "Applications"
	printf "  %-30s %s\n" "------" "------------"
	echo -e -n "${GREEN}"
	cnt=0
	while true ; do
		swarm=""; [ ${cnt} -lt ${#SWARMS[@]} ] && swarm=${SWARMS[$cnt]}
		app=""; [ ${cnt} -lt ${#APPS[@]} ] && app=${APPS[$cnt]}
		[ -z "${app}" -a -z "${swarm}" ] && break
		printf "  %-30s %s\n" "${swarm}" "${app}"
		cnt=`expr $cnt + 1`
	done
	echo -e -n "${BLUE}"
	

	# Ask the user what they would like to do
	echo1 ''
	cat << END
Commands:
  1. maintain a swarm
  2. maintain an application

  3. Show docker machines
  4. Send backup by email
  5. Define new application
  6. Define new swarm

  s. Shell
  q. Quit
END

	echo1 ''
	echon 'Selection: '
	read ans

	case "${ans}" in
	1)
		swarm=$(chooseSwarm)
		[ ! -z "${swarm}" ] && maintainSingleSwarm ${swarm}
		clear
		;;
	2)
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
	3)
		echo -e "${GREEN}"
		docker-machine ls
		echo -e "${BLUE}"
		;;
	4)
		emailBackup
		;;
	5)
		defineApp
		getAppNames
		;;
	6)
		createSwarm
		;;
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
