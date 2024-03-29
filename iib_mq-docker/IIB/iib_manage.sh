#!/bin/bash
# © Copyright IBM Corporation 2015.
#
# All rights reserved. This program and the accompanying materials
# are made available under the terms of the Eclipse Public License v1.0
# which accompanies this distribution, and is available at
# http://www.eclipse.org/legal/epl-v10.html

set -e

NODE_NAME=${NODENAME-IIBV10NODE}
MQ_QMGR_NAME=${MQ_QMGR_NAME}

stop()
{
	echo "----------------------------------------"
	echo "Stopping node $NODE_NAME..."
	sudo su - iibuser -c "mqsistop $NODE_NAME"
}

start()
{

	# HOST_EXISTS=`grep $HOSTNAME /etc/hosts ; echo $? `
	# if [ ${HOST_EXISTS} -ne 0 ]; then
	#     echo cat /etc/hosts
	#     cp /etc/hosts /tmp/hosts
	#     echo "Adding hostname $HOSTNAME to /etc/hosts..."
	#     sed "$ a 127.0.0.1 $HOSTNAME " -i /tmp/hosts
	#     cp /tmp/hosts /etc/hosts
	#     rm /tmp/hosts
	#     cat /etc/hosts
	# fi

	echo "----------------------------------------"
	sudo su - iibuser /opt/ibm/iib-10.0.0.9/iib version
	echo "----------------------------------------"

	NODE_EXISTS=`sudo su - iibuser -c mqsilist | grep $NODE_NAME > /dev/null ; echo $? `

	if [ ${NODE_EXISTS} -ne 0 ]; then
	    echo "----------------------------------------"
	    echo "Node $NODE_NAME does not exist..."
	    echo "Creating node $NODE_NAME"
	    sudo su - iibuser -c "mqsicreatebroker $NODE_NAME -q $MQ_QMGR_NAME"
	    echo "Starting syslog"
            sudo /usr/sbin/rsyslogd
	    echo "Starting node $NODE_NAME"
	    sudo su - iibuser -c "mqsistart $NODE_NAME"

	        sudo su - iibuser -c "mqsichangeproperties $NODE_NAME -b httplistener -o HTTPListener -n startListener -v true"
		sudo su - iibuser -c "mqsicreateexecutiongroup $NODE_NAME -e Core"
		sudo su - iibuser -c "mqsicreateexecutiongroup $NODE_NAME -e HRDEV"
		sudo su - iibuser -c "mqsicreateexecutiongroup $NODE_NAME -e HRDB"
		sudo su - iibuser -c "mqsichangeproperties $NODE_NAME -e Core -o ExecutionGroup -n soapNodesUseEmbeddedListener -v false"
		sudo su - iibuser -c "mqsichangeproperties $NODE_NAME -e HRDEV -o ExecutionGroup -n soapNodesUseEmbeddedListener -v false"
		sudo su - iibuser -c "mqsichangeproperties $NODE_NAME -e HRDB -o ExecutionGroup -n soapNodesUseEmbeddedListener -v false"

                #rm -rf /var/mqsi/shared-classes
                #ln -s /opt/iib/shared-classes /var/mqsi/shared-classes

		echo "Retarting $NODE_NAME..."
		sudo su - iibuser -c "mqsistop $NODE_NAME"
		sudo su - iibuser -c "mqsistart $NODE_NAME"
	else
	    echo "Starting syslog"
            sudo /usr/sbin/rsyslogd
	    sudo su - iibuser -c "mqsistart $NODE_NAME"
	fi
}

monitor()
{
	echo "----------------------------------------"
	echo "Running - stop container to exit"
	# Loop forever by default - container must be stopped manually.
	# Here is where you can add in conditions controlling when your container will exit - e.g. check for existence of specific processes stopping or errors beiing reported
	while true; do
		sleep 1
	done
}

iib-license-check.sh
start
trap stop SIGTERM SIGINT
monitor