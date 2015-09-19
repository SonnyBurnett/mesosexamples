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
IP_2ND_MSTR=$4
IP_3RD_MSTR=$5


echo   
echo "**********************************************************************"
echo "*                                                                    *"
echo "* Add the Mesosphere Repositories to your Hosts                      *"  
echo "*                                                                    *"  
echo "**********************************************************************" 
echo

apt-key adv --keyserver keyserver.ubuntu.com --recv E56151BF
DISTRO=$(lsb_release -is | tr '[:upper:]' '[:lower:]')
CODENAME=$(lsb_release -cs)
echo "deb http://repos.mesosphere.io/${DISTRO} ${CODENAME} main" | sudo tee /etc/apt/sources.list.d/mesosphere.list

echo   
echo "**********************************************************************"
echo "*                                                                    *"
echo "* Install the necessary components                                   *"  
echo "*                                                                    *"  
echo "**********************************************************************" 
echo

apt-get -y update
apt-get -y vim
apt-get install -y mesos 

echo   
echo "**********************************************************************"
echo "*                                                                    *"
echo "* Configure Zookeeper                                                *"  
echo "*                                                                    *"  
echo "**********************************************************************" 
echo

echo "zk://$IP_1ST_MSTR:2181,$IP_2ND_MSTR:2181,$IP_3RD_MSTR:2181/mesos" > /etc/mesos/zk

echo   
echo "**********************************************************************"
echo "*                                                                    *"
echo "* Stop Zookeeper and create override file so it will not auto start  *"  
echo "*                                                                    *"  
echo "**********************************************************************" 
echo

stop zookeeper
echo manual | tee /etc/init/zookeeper.override

echo   
echo "**********************************************************************"
echo "*                                                                    *"
echo "* Create override file so mesos-master will not auto start on slave  *"  
echo "*                                                                    *"  
echo "**********************************************************************" 
echo

echo manual | tee /etc/init/mesos-master.override
stop mesos-master

echo   
echo "**********************************************************************"
echo "*                                                                    *"
echo "* Set IP address and hostname                                        *"  
echo "*                                                                    *"  
echo "**********************************************************************" 
echo

echo $IP_THIS_VM | tee /etc/mesos-slave/ip
echo $HOSTNAME_THIS_VM > /etc/mesos-slave/hostname

#
# Prepare The Slave so it can run Docker containers.
#

echo 'docker,mesos' > /etc/mesos-slave/containerizers
echo '5mins' > /etc/mesos-slave/executor_registration_timeout

echo   
echo "**********************************************************************"
echo "*                                                                    *"
echo "* Install & configure docker                                         *"  
echo "*                                                                    *"  
echo "**********************************************************************" 
echo

apt-get install -y linux-image-generic-lts-trusty
apt-get install -y curl
curl -sSL https://get.docker.com/ | sh
usermod -aG docker ubuntu
docker -v

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