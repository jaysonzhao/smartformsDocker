#!/bin/bash
# © Copyright IBM Corporation 2015.
#
# All rights reserved. This program and the accompanying materials
# are made available under the terms of the Eclipse Public License v1.0
# which accompanies this distribution, and is available at
# http://www.eclipse.org/legal/epl-v10.html

NODE_NAME=${NODENAME-IIBV10NODE}

sudo su - iibuser -c "mqsichangeproperties $NODE_NAME -b httplistener -o HTTPListener -n startListener -v true"
sudo su - iibuser -c "mqsicreateexecutiongroup $NODE_NAME -e Core"
sudo su - iibuser -c "mqsicreateexecutiongroup $NODE_NAME -e HRDEV"
sudo su - iibuser -c "mqsicreateexecutiongroup $NODE_NAME -e HRDB"
sudo su - iibuser -c "mqsichangeproperties $NODE_NAME -e Core -o ExecutionGroup -n soapNodesUseEmbeddedListener -v false"
sudo su - iibuser -c "mqsichangeproperties $NODE_NAME -e HRDEV -o ExecutionGroup -n soapNodesUseEmbeddedListener -v false"
sudo su - iibuser -c "mqsichangeproperties $NODE_NAME -e HRDB -o ExecutionGroup -n soapNodesUseEmbeddedListener -v false"

rm -rf /var/mqsi/shared-classes
ln -s /opt/iib/shared-classes /var/mqsi/shared-classes

echo "Retarting $NODE_NAME..."
sudo su - iibuser -c "mqsistop $NODE_NAME"
sudo su - iibuser -c "mqsichangebroker $NODE_NAME -q ESB_QM"
sudo su - iibuser -c "mqsistart $NODE_NAME"
