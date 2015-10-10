#!/bin/bash
#
#	Send backup of config by email
#
BIN=$(dirname $0)

# Check we have email addresses
ADDRESS_FILE="${BIN}/NOTIFY_ADDRESSES"
if [ ! -r "${ADDRESS_FILE}" ] ; then
	echo "Error: Cannot find addresses file ${ADDRESS_FILE}"
	exit 1
fi
RECIPIENTS=`grep -v '^#' ${ADDRESS_FILE}`

# Create a summary of this backup and it's contents
PART1=SUMMARY_1.txt
PART2=SUMMARY_2.txt
DESCRIPTION_FILE=SUMMARY.txt
(
	# Header message
	echo ""
	echo ""
	echo "This is a backup of config files for a stick_in_the_hive build server."
	echo ""
	echo "DETAILS"
	echo "-------"
	echo "    machine:    $(hostname)"
	echo "    date:       $(date)"
	echo "    SSH_CLIENT: ${SSH_CLIENT}"
	echo ""
	echo "    See https://github.com/tooltwist/stick_in_the_hive."
	echo ""

	# Show the machines
	echo ""
	echo "MACHINES"
	echo "--------"
	docker-machine ls | sed 's/^/    /'
	echo ""
) 2>&1 | tee ${PART1}

(
	# Dump the applications
	echo ""
	echo "APPLICATIONS"
	echo "------------"
	(
		cd apps
		for n in * ; do
			if [ -d $n -a -d $n/.git ] ; then
				repo=$(cd $n; git remote -v | grep '(fetch)' | sed 's!origin\t\(.*\) .*!\1!' )
				brch=$(cd $n; git status | grep 'On branch' | sed 's!On branch !!')

				echo "* ${n}"
				echo "    repository: ${repo}"
				echo "    branch:     ${brch}"
				echo ""

			fi
		done
	)


	# Dump the swarms
	echo ""
	echo "SWARMS"
	echo "------"
	(
		cd swarms
		for n in * ; do
			if [ -d $n ] ; then

				echo "* ${n}"
				echo "    Mapped Applications:"
				(
					cd ${n}
					for app in * ; do
						if [ "${app}" = '*' ] ; then
							echo "      none"
						elif [ -d ${app} ] ; then
							echo "      ${app}"
						fi
					done
				)
				echo ""
				echo "    Current containers:"
				eval $(docker-machine env --swarm ${n}-swarm-master)
				docker ps -a | sed 's/^/    | /'
				echo ""

			fi
		done
	)

	echo ""
	echo "-------------"
	echo "END OF REPORT"
) 2>&1 | tee ${PART2}


#
#	Create the backup file
#	- textual description of swarms, applications, etc
#	- docker machine definitions
#	- SSH keys for user login
#	- swarm/app mappings
#
BACKUP=builder.`date +%Y%m%d-%H%M`.`hostname`.tar
cat ${PART1} ${PART2} > ${DESCRIPTION_FILE}
tar cf ${BACKUP} ${DESCRIPTION_FILE} .docker swarms .ssh/authorized_keys 

#
#	Send off the email
#
SUBJECT="stick-in-the-hive backup: $(hostname)"
echo ""
echo "Sending to:"
echo "${RECIPIENTS}"
echo ""
mutt -s "${SUBJECT}" ${RECIPIENTS} -a ${DESCRIPTION_FILE} ${BACKUP} < ${PART1}
