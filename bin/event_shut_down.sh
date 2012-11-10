#! /bin/bash -eu

# The script is used to shutdown the system by monitoring other processes
# Usually waiting for a certain process to finish

# Test root user
if [ $UID -ne 0 ]; then
	echo "Need to be root, exiting ..."
	exit 1
fi

# The usage
if [ $# -ne 1 ]; then
	echo "Usage: $(basename $0) <process id>"
	exit 1
fi

# initializtion
pid=$1
pdir=/proc/$pid
wait_time=1   # 1 minute before shutting down

# Test if the process id exists or not
if [ ! -d $pdir ]; then
	echo "Looks like process id $pid does not exist, exiting ..."
	exit 1
fi

# Loop to wait and then shutdown the system
while [ -d $pdir ]
do
	echo "[ $(date) ] | Process $pid is still running ..."
	sleep 300
done

# shut down the system
shutdown -P +1

