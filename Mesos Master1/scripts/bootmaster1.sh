#!/usr/bin/env bash

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
apt-get install -y vim
apt-get install -y mesosphere 

echo   
echo "**********************************************************************"
echo "*                                                                    *"
echo "* Configure Zookeeper                                                *"  
echo "*                                                                    *"  
echo "**********************************************************************" 
echo

echo "zk://192.168.33.41:2181,192.168.33.42:2181/mesos" > /etc/mesos/zk
echo "1" > /etc/zookeeper/conf/myid
echo "server.1=192.168.33.41:2888:3888" >> /etc/zookeeper/conf/zoo.cfg
echo "server.2=192.168.33.42:2888:3888" >> /etc/zookeeper/conf/zoo.cfg

echo   
echo "**********************************************************************"
echo "*                                                                    *"
echo "* Configure Mesos                                                    *"  
echo "*                                                                    *"  
echo "**********************************************************************" 
echo

echo "2" > /etc/mesos-master/quorum
echo "192.168.33.41" | tee /etc/mesos-master/ip
cp /etc/mesos-master/ip /etc/mesos-master/hostname

echo   
echo "**********************************************************************"
echo "*                                                                    *"
echo "* Configure Marathon                                                 *"  
echo "*                                                                    *"  
echo "**********************************************************************" 
echo

mkdir -p /etc/marathon/conf
cp /etc/mesos-master/hostname /etc/marathon/conf
cp /etc/mesos/zk /etc/marathon/conf/master
cp /etc/marathon/conf/master /etc/marathon/conf/zk
sed -i 's/mesos/marathon/g' /etc/marathon/conf/zk

echo   
echo "**********************************************************************"
echo "*                                                                    *"
echo "* (re)start services                                                 *"  
echo "*                                                                    *"  
echo "**********************************************************************" 
echo

stop mesos-slave
echo manual | tee /etc/init/mesos-slave.override

# restart zookeeper
# start mesos-master
# start marathon

ifconfig
exit 0