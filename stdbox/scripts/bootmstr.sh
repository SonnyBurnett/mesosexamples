#!/usr/bin/env bash
#
#
# Author:      Taco Bakker
#
# Purpose:	   Provision a VM with Mesos, Marathon, Zookeeper (Mesosphere) and Docker.
#              To demonstrate how to run Docker containers on a High Available Mesos Cluster.
#
# Description: Provision Mesos Masters
#

#
# Define main variables
#

IP_THIS_VM=$1
HOSTNAME_THIS_VM=$2
ID_THIS_VM=$3
IP_1ST_MSTR=$4
ID_1ST_MSTR=$5

QUORUM_ZK="1"

stop mesos-master
stop marathon
stop chronos

echo   
echo "**********************************************************************"
echo "*                                                                    *"
echo "* Configure Zookeeper                                                *"  
echo "*                                                                    *"  
echo "**********************************************************************" 
echo

#
# The file /etc/mesos/zk must contain the ip addresses of all the Mesos Masters,
# The file /etc/zookeeper/conf/myid must contain a unique ID for this Mesos Master.
# For every Mesos Master a line must be added to the file /etc/zookeeper/conf/zoo.cfg
# to map each ID to a host
#

echo "zk://$IP_1ST_MSTR:2181/mesos" > /etc/mesos/zk
echo $ID_THIS_VM > /etc/zookeeper/conf/myid

echo "server.$ID_1ST_MSTR=$IP_1ST_MSTR:2888:3888" >> /etc/zookeeper/conf/zoo.cfg

echo   
echo "**********************************************************************"
echo "*                                                                    *"
echo "* Configure Mesos                                                    *"  
echo "*                                                                    *"  
echo "**********************************************************************" 
echo

#
# First set the Quorum, which is the minimum number of Masters that must be available for the cluster to work.
# Normally it should be set on a number > 50% of the number of Masters.
# To make sure our instance can resolve correctly the ip address is set in the file ip
# and the ip address is also used as the Hostname. 
#

echo $QUORUM_ZK > /etc/mesos-master/quorum
echo $IP_THIS_VM | tee /etc/mesos-master/ip
echo $HOSTNAME_THIS_VM > /etc/mesos-master/hostname

echo   
echo "**********************************************************************"
echo "*                                                                    *"
echo "* Configure Marathon                                                 *"  
echo "*                                                                    *"  
echo "**********************************************************************" 
echo

echo $IP_THIS_VM > /etc/marathon/conf/hostname
echo "zk://$IP_1ST_MSTR:2181/mesos" > /etc/marathon/conf/master
echo "zk://$IP_1ST_MSTR:2181/marathon" > /etc/marathon/conf/zk

echo   
echo "**********************************************************************"
echo "*                                                                    *"
echo "* (re)start services                                                 *"  
echo "*                                                                    *"  
echo "**********************************************************************" 
echo

stop mesos-slave
echo manual | tee /etc/init/mesos-slave.override

restart zookeeper
start mesos-master
start marathon
start chronos


sed -i s/DUMMY/"$IP_1ST_MSTR"/g /vagrant/scripts/startmesos.sh

ifconfig

exit 0