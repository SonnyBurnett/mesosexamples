#!/usr/bin/env bash

echo "**********************************************************************"
echo "*                                                                    *"
echo "* Set hostname                                                       *"
echo "*                                                                    *"
echo "**********************************************************************"
echo "mesos-master" | sudo tee /etc/hostname
sudo hostname mesos-master

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

add-apt-repository -y ppa:openjdk-r/ppa
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

echo "zk://192.168.33.46:2181/mesos" > /etc/mesos/zk
echo "1" > /etc/zookeeper/conf/myid
echo "server.1=192.168.33.46:2888:3888" >> /etc/zookeeper/conf/zoo.cfg

echo   
echo "**********************************************************************"
echo "*                                                                    *"
echo "* Configure Mesos                                                    *"  
echo "*                                                                    *"  
echo "**********************************************************************" 
echo

echo "1" > /etc/mesos-master/quorum
echo "192.168.33.46" | tee /etc/mesos-master/ip
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

restart zookeeper
start mesos-master
start marathon
echo   
echo "**********************************************************************"
echo "*                                                                    *"
echo "* Set IP address and hostname                                        *"  
echo "*                                                                    *"  
echo "**********************************************************************" 
echo

echo "192.168.33.46" | tee /etc/mesos-slave/ip
cp /etc/mesos-slave/ip /etc/mesos-slave/hostname

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
echo "* Install & configure docker                                         *"  
echo "*                                                                    *"  
echo "**********************************************************************" 
echo

apt-get install -y linux-image-generic-lts-trusty
apt-get install -y curl
curl -sSL https://get.docker.com/ | sh
usermod -aG docker ubuntu
docker -v
#curl -L https://github.com/docker/compose/releases/download/VERSION_NUM/docker-compose-`uname -s`-`uname -m` > /usr/local/bin/docker-compose
#chmod +x /usr/local/bin/docker-compose
apt-get install -y python-pip
pip install -U docker-compose
docker-compose --version


ifconfig
exit 0