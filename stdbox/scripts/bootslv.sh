#!/usr/bin/env bash
#
#
# Author:      Taco Bakker
#
# Purpose:	   Provision a VM with Mesos, Marathon, Zookeeper (Mesosphere) and Docker.
#              To demonstrate how to run Docker containers on a High Available Mesos Cluster.
#
# Description: Provision Mesos Slaves
#

#
# Define main variables
#

IP_THIS_VM=$1
HOSTNAME_THIS_VM=$2
IP_1ST_MSTR=$3

stop mesos-slave

echo   
echo "**********************************************************************"
echo "*                                                                    *"
echo "* Configure Zookeeper                                                *"  
echo "*                                                                    *"  
echo "**********************************************************************" 
echo

echo "zk://$IP_1ST_MSTR:2181/mesos" > /etc/mesos/zk

echo   
echo "**********************************************************************"
echo "*                                                                    *"
echo "* Set IP address and hostname                                        *"  
echo "*                                                                    *"  
echo "**********************************************************************" 
echo

echo $IP_THIS_VM | tee /etc/mesos-slave/ip
echo $HOSTNAME_THIS_VM > /etc/mesos-slave/hostname

echo   
echo "**********************************************************************"
echo "*                                                                    *"
echo "* Start mesos-slave                                                  *"  
echo "*                                                                    *"  
echo "**********************************************************************" 
echo

start mesos-slave

ifconfig
exit 0