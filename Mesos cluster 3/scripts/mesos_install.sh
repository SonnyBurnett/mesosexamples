#!/usr/bin/env bash
#
#
# Author:      Taco Bakker
#
# Purpose:	   Provision a VM with Mesos, Marathon, Zookeeper (Mesosphere) and Docker.
#              To demonstrate how to run Docker containers on a High Available Mesos Cluster.
#
# Description: This script is used in combination with Vagrant.
#              First step is to install Mesosphere, 
#              which includes Mesos (Master & Slave), Mesos Frameworks (Marathon & Chronos)
#              and Zookeeper for High Availability of Distributed systems
#              Second step is to configure Zookeeper, Mesos (Master) and Marathon.
#              So they can find each other and run as one cluster.
#              Third is the configuration of the Mesos Slave.
#              And finally Docker is installed
#


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
echo "* Install the necessary components and update the system             *"  
echo "*                                                                    *"  
echo "**********************************************************************" 
echo

apt-get -y update
apt-get install -y vim
apt-get install -y mesosphere 

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

echo "zk://$IP_THIS_VM:2181,$IP_2ND_MSTR:2181/mesos" > /etc/mesos/zk
echo $ID_THIS_VM > /etc/zookeeper/conf/myid
echo "server.$ID_THIS_VM=$IP_THIS_VM:2888:3888" >> /etc/zookeeper/conf/zoo.cfg
echo "server.$ID_2ND_MSTR=$IP_2ND_MSTR:2888:3888" >> /etc/zookeeper/conf/zoo.cfg

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

#
# First create the directory for Marathon configuration, which is not done on installation.
# Than create the config files for marathon
#

mkdir -p /etc/marathon/conf
echo $IP_THIS_VM > /etc/marathon/conf/hostname
echo "zk://$IP_THIS_VM:2181/mesos" > /etc/marathon/conf/master
echo "zk://$IP_THIS_VM:2181/marathon" > /etc/marathon/conf/zk

echo   
echo "**********************************************************************"
echo "*                                                                    *"
echo "* (re)start services                                                 *"  
echo "*                                                                    *"  
echo "**********************************************************************" 
echo

# 
# Just in case stop any Mesos Slave processes that might be running
# And avoid them to run at boot.
# Hmmm not sure this is what we want...
# stop mesos-slave
# echo manual | tee /etc/init/mesos-slave.override

restart zookeeper
start mesos-master
start marathon

echo   
echo "**********************************************************************"
echo "*                                                                    *"
echo "* Configure the Mesos Slave                                          *"  
echo "*                                                                    *"  
echo "**********************************************************************" 
echo

# 
# It is not standard to run the Slave on the same VM as the Master.
# But it can be done.
#

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
echo "* Start mesos-slave                                                  *"  
echo "*                                                                    *"  
echo "**********************************************************************" 
echo

start mesos-slave

echo   
echo "**********************************************************************"
echo "*                                                                    *"
echo "* Start chronos                                                      *"  
echo "*                                                                    *"  
echo "**********************************************************************" 
echo

start chronos

echo   
echo "**********************************************************************"
echo "*                                                                    *"
echo "* Install & configure docker and docker compose                      *"  
echo "*                                                                    *"  
echo "**********************************************************************" 
echo

apt-get install -y linux-image-generic-lts-trusty
apt-get install -y curl
curl -sSL https://get.docker.com/ | sh
usermod -aG docker ubuntu
docker -v
apt-get install -y python-pip
pip install -U docker-compose
docker-compose --version
docker-compose --version

#
# pull a Docker image from the Docker hub 
# and start it in Marathon
# to demonstrate how it all works.
#

docker pull jenkins
# /vagrant/scripts/startmesos.sh jenkins

ifconfig
