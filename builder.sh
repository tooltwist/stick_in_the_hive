#!/bin/sh
#
#	Script for creating a Docker swarm
#

# Color codes
#http://bitmote.com/index.php?post/2012/11/19/Using-ANSI-Color-Codes-to-Colorize-Your-Bash-Prompt-on-Linux
B="\033[1m"
D="\033[0;37m"
N="\033[m"
RED="\033[0;31m"
BLUE="\033[0;34m"
AQUA="\033[0;36m"
GREEN="\033[0;32m"
PURPLE="\033[0;35m"
ORANGE="\033[1;33m"


function defineApp {
	clear
	echo ${BLUE}
	echo ""
	echo Define an application
	echo '____________________'
	echo ''

	# Get a unique app name
	name=""
	while [ -z "${name}" ] ; do
		echo "${BLUE}App name: ${RED}\c"
		read name
		echo "${BLUE}\c"
		if [ -e apps/${name} ] ; then
			echo "Name is already used"
			name=""
		fi
	done
	echo "${BLUE}Github path: ${RED}\c"
	read path
	echo "${BLUE}\ctec"

	# Clone the repository as a new app
	echo ''
	echo "Cloning repository:"
	(
		cd apps
		git clone ${path} ${name}
		echo git clone ${path} ${name}
		rv=$?
		echo Exit status is $rv
	)
	echo ${N}
}

#
#	Show the containers in the swarm
#
#
function swarmPS {
	swarm=$1
	
	(
		echo ${BLUE}
		clear
		echo "Containers in Swarm ${swarm}"
		echo "____________________________"
		echo ""
		echo ""
		echo '$ eval $(docker-machine env --swarm '${swarm}'-swarm-master)'
		eval $(docker-machine env --swarm ${swarm}-swarm-master)
		env | grep DOCKER
		echo ""
		echo ${GREEN}
		docker ps
#		docker ps | grep -v jwilder/nginx-proxy
		echo ${N}
		echo ""
		echo ""
		echo ""
		echo ""
	)
}

#
#	Show the containers in the swarm
#
#
function swarmInfo {
	swarm=$1
	
	(
		echo ${BLUE}
		clear
		echo "Containers in Swarm ${swarm}"
		echo "____________________________"
		echo ""
		echo ""
		echo '$ eval $(docker-machine env --swarm '${swarm}'-swarm-master)'
		eval $(docker-machine env --swarm ${swarm}-swarm-master)
		env | grep DOCKER
		echo ""
		echo '$ docker info'
		echo ${GREEN}
		        docker info
		echo ${N}
		echo ""
		echo ""
		echo ""
		echo ""
	)
}

#
#	Create an extra swarm mode
#
function addSwarmNode {
	echo ""
	echo ""
	echo ""
	echo ""
	echo ""
	echo Sorry, not adding nodes yet.
	echo ""
	echo ""
	echo ""
	echo ""
	echo ""
	echo ""
	echo "Press Enter to continue: \c"
	read ans
}



#
#	Initialize tooltwist.js
#
function initCLI {
	app=$1
	echo ${BLUE}
	clear
	echo 'Init ToolTwist CLI in Docker mode'
	echo '_________________________________'
	echo ''
	
	# Get the repo name
	echo '$ git remote -v'
	o=$(git remote -v)
	repo=$(echo ${o} | sed 's!origin.\(.*\).(fetch).*!\1!')
	echo repo is ${repo}.

	# Initialize tooltwist
	(
		mkdir -p deploy/docker
		echo '$ cd deploy/docker'
		cd deploy/docker
		echo '$ tooltwist init docker'
		echo ${GREEN}
		tooltwist init docker
		echo ${BLUE}
		
		# Patch the config file
		sed -i '' 's!"name" : "ttdemo"!"name" : "'${app}'"!' tooltwist.js
		sed -i '' 's!https://github.com/tooltwist/ttdemo.git!'${repo}'!' tooltwist.js
		sed -i '' 's!id: .my-project.,!id: "'${app}'",!' tooltwist.js
	)
	
	#	Create a build script
	createBuildForCLI
	echo ${N}
}

#
#	Create a build.sh to start 'tooltwist docker'
#
function createBuildForCLI {
	echo 'Creating build.sh...'
	echo '#!/bin/bash' > deploy/docker/build.sh
	echo 'tooltwist docker' >> deploy/docker/build.sh
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
	echo ${BLUE}
	clear
	echo 'Run ToolTwist Designer'
	echo '______________________'
	echo ''
	
	# Use the project as it's own webdesign
#	echo "$ mkdir -p deploy/docker/.tooltwist/webdesign-projects"
#	mkdir -p deploy/docker/.tooltwist/webdesign-projects
	echo "$ rm -f deploy/docker/.tooltwist/webdesign-projects/${app}"
	rm -rf deploy/docker/.tooltwist/webdesign-projects/${app}
#	here=`pwd`
#	echo "$ ln -s ${here} deploy/docker/.tooltwist/webdesign-projects/${app}"
#	ln -s ${here} deploy/docker/.tooltwist/webdesign-projects/${app}
	
	# Run the Designer
	(
		echo ''
		echo "${RED}When you finish, press Ctrl-C${BLUE}"
		echo ''

		echo '$ cd deploy/docker'
		cd deploy/docker
		echo '$ tooltwist designer'
		echo "${GREEN}\n"
		trap true SIGINT
		tooltwist designer
		trap - SIGINT
		echo "${N}\n"
	)
}

#
#	Build the Docker image
#
function doBuild {
	app=$1
	echo ${BLUE}
	clear
	echo 'Build Docker image'
	echo '__________________'
	echo ''
	
	# Use the project as it's own webdesign
#	echo "$ mkdir -p deploy/docker/.tooltwist/webdesign-projects"
#	mkdir -p deploy/docker/.tooltwist/webdesign-projects
#	echo "$ rm -f deploy/docker/.tooltwist/webdesign-projects/${app}"
#	rm -rf deploy/docker/.tooltwist/webdesign-projects/${app}
	
	(
		echo '$ cd deploy/docker'
		cd deploy/docker
		echo "${N}\n"
		trap true SIGINT
		echo '$ tooltwist -n docker'
		echo '$ eval $(docker-machine env default)'
		eval $(docker-machine env default)
		echo "${RED}"
		env | grep DOCKER
		
		echo "${N}"
		tooltwist docker
		trap - SIGINT
		echo "${N}\n"
		
		docker images
	)
}

#
#	Start a shell in the application's deploy directory
#
function appDockerDirShell {
	app=$1
	(
		echo ''
		echo 'When you finish, press Ctrl-D'
		echo ''
		cd deploy/docker
		/bin/bash --login
	)
	
}

#
#	Start a shell in the application's deploy directory
#
function appShell {
	app=$1
	(
		echo ''
		echo 'When you finish, press Ctrl-D'
		echo ''
		/bin/bash --login
	)
	
}

#
#	Start a shell in the swarm's deploy directory
#
function swarmShell {
	swarm=$1
	(
		echo ''
		echo 'When you finish, press Ctrl-D'
		echo ''
		cd swarms/$swarm
		/bin/bash --login
	)
	
}

#
#	View local image
#
function viewLocalImage {
	app=$1
	echo ${GREEN}
	clear
	echo 'Local Images'
	echo '____________'
	echo ''
	docker $(docker-machine config default) images | grep -e 'REPOSITORY' -e "${app}"
	echo ${N}
	echo ""
	echo ""
	echo ""
	echo ""
}

#
#	View image on Docker Hub
#
function viewDockerHubImage {
	app=$1
	echo ${ORANGE}
	clear
	echo 'Images at Docker Hub'
	echo '____________________'
	echo ''
	docker $(docker-machine config default) search tooltwist/${app}
	echo ${N}
	echo ""
	echo ""
	echo ""
	echo ""
}

#
#	Push image to Docker Hub
#
function pushToDockerHub {
	app=$1
	echo ${GREEN}
	docker $(docker-machine config default) images | grep -e 'REPOSITORY' -e "${app}"
	echo ${N}
	
	# Get the tag
	echo "Will push as tooltwist/${app}"
	echo "What tag should be used? \n"
	read ans
	
	if [ ! -z "${ans}" ] ; then
		
		echo NOT PUSHING YET
	fi
	echo ""
	echo ""
	echo ""
	echo ""
}

#
#	Menu for ToolTwist applications
#
function tooltwistAppMenu {
	app=$1
	pwd
	
	# See if we have a build config
	buildColor=${D}
	[ -e build/tooltwist.js ] && buildColor=${B}
	
	# See if we have a Compose script
	
	
	while true ; do
		echo "______________________________________________________"
		echo ""
		echo "	      TOOLTWIST APPLICATION ${app}"
		echo "______________________________________________________"
		echo ""


		# Is a ToolTwist project
		mayBuild=N
		mayInitCLI=N
		haveConf=N

		if [ -e deploy/docker/tooltwist.js ] ; then
			echo Found tooltwist.js
			haveConf=Y

			# See if we have a build script
			[ -e deploy/docker/build.sh ] && createBuildForCLI ${app}
			mayBuild=Y
		else
			echo Missing tooltwist.js
			mayInitCLI=Y
		fi
		
		
		cInit=${D}; [ ${mayInitCLI} == 'Y' ] && cInit=${B};
		cEdit=${D}; [ ${haveConf} == 'Y' ] && cEdit=${N};
		cRun=${D}; [ ${haveConf} == 'Y' ] && cRun=${N};
		cBuild=${D}; [ ${mayBuild} == 'Y' ] && cBuild=${B};
		
		
		# Initialise the build with ToolTwist CLI
		
		echo "	Create:"
		echo "	  ${cInit}1. Initialise ToolTwist CLI${N}"
		echo "	  ${cEdit}2. Edit toolTwist.js${N}"
		echo "	  ${cRun}3. Run Designer${N}"
		echo "	  ${cBuild}4. Build Docker image${N}"
		echo "	  ${N}5. Shell in docker directory${N}"
		echo ""


cat << END
	Publish:
	  6. Show image on this machine
	  7. Show image on Docker Hub
	  8. Push image to Docker hub

	Run:
	  9. View swarm
	  10. Edit docker-compose.yml
	  11. Start application
	  12. Stop application

	  s. Shell
	  f. Finish with this App
END

		echo ''
		echo 'Enter selection: \c'
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
		echo "______________________________________________________"
		echo ""
		echo "	            APPLICATION ${app}"
		echo "______________________________________________________"
		echo ""

		# See what we're allowed to do.
		mayEdit=N
		mayBuild=N	
		if [ -e deploy/docker/build.sh ] ; then
			mayBuild=Y
			echo Have build.sh
		fi
		cEdit=${D}; [ ${mayEdit} == 'Y' ] && cEdit=${B};
		cBuild=${D}; [ ${mayBuild} == 'Y' ] && cBuild=${B};
		
		
		# Initialise the build with ToolTwist CLI
		
echo "	Create:"
echo "	  ${N}1. Edit build.sh${N}"
echo "	  ${cBuild}2. Build Docker image${N}"
echo ""


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
	
		echo '	Enter selection: \c'
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
		echo "${BLUE}"
		echo "______________________________________________________"
		echo ""
		echo "	                 MAINTAIN SWARMS"
		echo "______________________________________________________"
		echo ""

		# Show the existing swarms
		echo "${GREEN}"
#		echo swarms is ${SWARMS[@]}
		echo '	Swarms:'
		for s in "${SWARMS[@]}"; do
			echo "	  ${s}"
		done
		echo ''
		echo "${BLUE}"

		cat << END
	Menu:
	  1. Create a new swarm

	  s. Shell
	  f. Finish with this menu
		
END
	
		echo "	${BLUE}Enter selection: ${RED}\c"
		read ans
		echo "${N}\c"
	
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
				echo checking ${n}
				if echo ${n} | grep "${ans}" ; then
					echo found
					swarm=${n}
					cnt=`expr $cnt + 1`
				fi
			done
			echo ""
			if [ ${cnt} -eq 0 ] ; then
				echo "${RED}Swarm ${ans} not found${N}"
				echo ""
				echo ""
				echo "Press ENTER to continue: \c"
				return
			elif [ ${cnt} -gt 1 ] ; then
				echo "${RED}More than oen swarm matches ${ans}${N}"
				echo ""
				echo ""
				echo "Press ENTER to continue: \c"
				return
			fi
			echo swarm is ${swarm}
			maintainSingleSwarm ${swarm}
		esac
	done
}

#
#	Create a new swarm
#
function createSwarm {
	
	echo 'Name of swarm: \c'
	read name
	
	# Check the name is valid
	[ -z ${name} ] && return
	found=N
	for n in ${SWARMS[@]} ; do
		echo check $n
		[ ${n} == ${name} ] && found=Y
	done
	if [ ${found} == 'Y' ] ; then
		echo 'This name is already used'
		return
	fi
	
	(
		# Run the swarm image (only) on the current machine.
		# NOTE: This container is used to register our new
		# swarm with the docker name registry, and to get a
		# tokan that can be used by the swarm nodes to
		# communicate with each other.
		echo 'Getting a token to identify the swarm...'
		echo ''
		echo '$ eval $(docker-machine env default)'
		eval $(docker-machine env default)
	
		# Get the new swarm token
		echo '$ docker pull swarm'
		docker pull swarm
		
		echo '$ docker run --rm swarm create'
		SWARM_TOKEN=$(docker run --rm swarm create)
		if [ $? -ne 0 ] ; then
			echo 'Could not create swarm token'
			return
		fi
		echo ''
		echo 'New swarm token is' ${SWARM_TOKEN}.
	
		#
		# Create the swarm Master
		#
		DO_ACCESS_TOKEN=`cat DO_ACCESS_TOKEN`
		REGION=sgp1
		SIZE=2gb

		#
		#	Create one worker-only node
		#
		echo >&2 "Creating Docker Swarm cluster"
		
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
	maintainSingleSwarm ${swarm}
}


#
#	maintain a single swarm
#
function maintainSingleSwarm {
	swarm=$1
	
	
	(
		eval $(docker-machine env --swarm ${swarm}-swarm-master)
	
	
		while true ; do
			echo "${BLUE}"
			echo "______________________________________________________"
			echo ""
			echo "	            MAINTAIN SWARM ${swarm}"
			echo "______________________________________________________"
			echo ""
			
			listApps ${swarm}
			

			cat << END
	Menu:
	  1. Swarm Containers
	  2. Swarm Info
  
	  3. Start proxy
	  4. Stop proxy
	  5. Restart proxy
	  
	  6. Start application
	  7. Stop application
	  8. Restart application
  
	  s. Shell
	  f. Finish with this menu
		
END
	
			echo "	${BLUE}Enter selection: ${RED}\c"
			read ans
			echo "${N}\c"
	
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
				startApp ${swarm} ${ans} 'up -d'
				;;
			7)
				startApp ${swarm} ${ans} stop
				;;
			8)
				startApp ${swarm} ${ans} restart
				;;
			s)
				swarmShell ${swarm}
				;;
			f)
				return
				;;
			*)
				echo "${RED}Unknown command"
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
	echo "${BLUE}"
	echo ""
	echo " Start Proxy for Swarm"
	echo "_______________________"
	
	(

		# Set the environment
		echo ''
		echo '$ eval "$(docker-machine env --swarm '${swarm}'-swarm-master)"'
		eval "$(docker-machine env --swarm ${swarm}-swarm-master)"

		# Copy certificates to the proxy server
		echo >&2 "Copying TLS config to swarm-proxy"
		echo '$ docker-machine scp -r "$DOCKER_CERT_PATH" '${swarm}'-swarm-proxy:/tmp/docker-certs'
		docker-machine scp -r "$DOCKER_CERT_PATH" ${swarm}-swarm-proxy:/tmp/docker-certs
	
		# Prepare the environment
		echo >&2 "Prepare environment file for Compose:"
		cat <<EOF | tee proxy.env >&2
DOCKER_TLS_VERIFY=1
DOCKER_HOST=tcp://$(docker-machine ip ${swarm}-swarm-master):3376
DOCKER_CERT_PATH=/tmp/docker-certs
constraint:type==proxy
EOF
		echo ""
		
		# Start the nginx container, and limit it to one instance
		echo >&2 "Starting services via Docker Compose"
		echo ''
		echo '$ docker-compose -f docker-production-swarm-proxy.yml up -d'
		docker-compose -f docker-production-swarm-proxy.yml up -d
		echo ''
		echo '$ docker-compose -f docker-production-swarm-proxy.yml scale proxy=1'
		docker-compose -f docker-production-swarm-proxy.yml scale proxy=1
	)
}


#
#	Stop nginx-proxy on the swarm
#
function stopProxy {
	swarm=$1
	clear
	echo "${BLUE}"
	echo ""
	echo " Stop Proxy for Swarm"
	echo "______________________"
	
	(
		# Set the environment
		echo ''
		echo '$ eval "$(docker-machine env --swarm '${swarm}'-swarm-master)"'
		eval "$(docker-machine env --swarm ${swarm}-swarm-master)"
	
		# Prepare the environment
		echo >&2 "Prepare environment file for Compose:"
		cat <<EOF | tee proxy.env >&2
DOCKER_TLS_VERIFY=1
DOCKER_HOST=tcp://$(docker-machine ip ${swarm}-swarm-master):3376
DOCKER_CERT_PATH=/tmp/docker-certs
constraint:type==proxy
EOF
		echo ""
		
		# Start the nginx container, and limit it to one instance
		echo >&2 "Starting services via Docker Compose"
		echo ''
		echo '$ docker-compose -f docker-production-swarm-proxy.yml stop'
		docker-compose -f docker-production-swarm-proxy.yml stop
	)
}


#
#	Restart nginx-proxy on the swarm
#
function restartProxy {
	swarm=$1
	clear
	echo "${BLUE}"
	echo ""
	echo " Restart Proxy for Swarm"
	echo "_________________________"
	
	(
		# Set the environment
		echo ''
		echo '$ eval "$(docker-machine env --swarm '${swarm}'-swarm-master)"'
		        eval "$(docker-machine env --swarm "${swarm}"-swarm-master)"
	
		# Prepare the environment
		echo >&2 "Prepare environment file for Compose:"
		cat <<EOF | tee proxy.env >&2
DOCKER_TLS_VERIFY=1
DOCKER_HOST=tcp://$(docker-machine ip ${swarm}-swarm-master):3376
DOCKER_CERT_PATH=/tmp/docker-certs
constraint:type==proxy
EOF
		echo ""
		
		# Start the nginx container, and limit it to one instance
#		echo >&2 "Starting services via Docker Compose"
		echo ''
		echo '$ docker-compose -f docker-production-swarm-proxy.yml restart'
		        docker-compose -f docker-production-swarm-proxy.yml restart
	)
}

function listApps {
	swarm=$1
	
	# List the applications mapped to this swarm
	(
		mkdir -p swarms/${swarm}
		cd swarms/${swarm}
	
		echo ""
		echo "	Applications for this swarm:"
		echo "${GREEN}"
		for n in * ; do
			if [ "${n}" != "*" ] ; then
				[ ${n}/docker-compose.yml ] && echo "	  ${n}"
			fi
		done
		echo "${BLUE}"
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
	echo "${BLUE}"
	echo ""
	echo " Start Application"
	echo "__________________"
	
	# Ask the app name
	listApps ${swarm}
	
#	app=askApp
	echo ""
	echo "Which application to start? \c"
	read ans
	
	# Check the application exists
	cnt=0
	for n in swarms/${swarm}/* ; do
		echo checking ${n}
		base=`basename ${n}`
		if echo ${base} | grep "${ans}" ; then
			echo found
			app=${base}
			cnt=`expr $cnt + 1`
		fi
	done
	echo ""
	if [ ${cnt} -eq 0 ] ; then
		echo "${RED}App ${ans} not found${N}"
		echo ""
		echo ""
		echo "Press ENTER to continue: \c"
		return
	elif [ ${cnt} -gt 1 ] ; then
		echo "${RED}More than one app matches ${ans}${N}"
		echo ""
		echo ""
		echo "Press ENTER to continue: \c"
		return
	fi
	echo app is ${app}
	
	(
		cd swarms/${swarm}/${app}
		echo '$ cd' `pwd`
		
		# Check we have the required files
		if [ ! -r VIRTUAL_HOST -o ! -r VIRTUAL_PORT ] ; then
			echo ""
			echo "${RED}App ${app} needs to define files VIRTUAL_HOST and VIRTUAL_PORT"
			echo "${N}"
			askEnter
			clear
			return
		fi
		VIRTUAL_HOST=`cat VIRTUAL_HOST`
		VIRTUAL_PORT=`cat VIRTUAL_PORT`
		
		if [ ! -f docker-compose.yml ] ; then
			echo ""
			echo "${RED}App ${app} needs to define docker-compose.yml"
			echo "${N}"
			askEnter
			clear
			return
		fi

		# Set the environment for the swarm
		echo ''
		echo '$ eval "$(docker-machine env --swarm '${swarm}'-swarm-master)"'
		eval "$(docker-machine env --swarm ${swarm}-swarm-master)"

		# Prepare the environment for the application
		echo >&2 "Prepare environment file for Compose:"
		cat <<EOF | tee app.env >&2
VIRTUAL_HOST=${VIRTUAL_HOST}
VIRTUAL_PORT=${VIRTUAL_PORT}
constraint:type==app
EOF
		echo ""
		
		# Start the nginx container, and limit it to one instance
		echo >&2 "Starting services via Docker Compose"
		echo ''
		echo '$ docker-compose '${op}
		        docker-compose ${op}
		if [ ${op} == 'start' ] ; then
			echo ''
			echo '$ docker-compose scale app=1'
			        docker-compose scale app=1
		fi
	)
}


#
#	Get the names of the available swarms
#
function getSwarmNames {
	SWARMS=( `docker-machine ls | grep -e '^\S*-swarm-master ' | sed 's! .*!!' | sed 's!^\(.*\)-swarm-master$!\1!'` )	
}

function askEnter {
	echo ""
	echo "${RED}Press ENTER to continue: \c${BLUE}"
	read ans
}


#
#	Start here
#

# Set the environment
echo Checking environment variables to access swarm
eval $(docker-machine env --swarm swarm-masterz)
env | grep DOCKER

echo Checking existing swarm names
getSwarmNames
echo done.
echo ''

# Check we have the required directories
mkdir -p apps
while true ; do
	
	# Show existing applications
	echo "______________________________________________________"
	echo ""
	echo "            TOOLTWIST BUILDER MAIN MENU               "
	echo "______________________________________________________"
	echo ""
	echo ""
	echo "Applications:"
	(
		cd apps
		for n in * ; do
			echo "  $n"
			#cat $n
		done
	)

	# Ask the user what they would like to do
	echo ''
	cat << END
Commands:
  1. Define new application.
  2. Maintain swarms.
  s. Shell
  q) Quit
END

	echo ''
	echo 'Enter application name or a menu selection: \c'
	read ans

	case "${ans}" in
	1)
		defineApp
		;;
	2)
		maintainSwarms
		;;
#	3)
#		addSwarmNode
#		;;
	s)
		appShell
		;;
	q)
		echo Bye.
		exit 0;
		;;
		
	"")
		# Null selection
		echo ""
		echo "Hey, you are supposed to enter something!"
		;;
		
	*)
		# Look for an application name
		(
			cd apps
			cnt=0
			for n in ${ans}* ; do
				cnt=`expr ${cnt} + 1`
				app=$n
			done
			
			if [ ${cnt} -eq 1 -a ${n} != "${ans}*" ] ; then
				# Show the menu for this application
				cd ${app}
				if [ -d navpoints -a -d widgets ] ; then
					tooltwistAppMenu ${app}
				else
					otherAppMenu ${app}
				fi
			elif [ ${cnt} -gt 1 ] ; then
				echo "Please enter more characters, to specify a single app."
			else
				echo "No application matches ${ans}*"
			fi
		)
		;;
	esac
done
