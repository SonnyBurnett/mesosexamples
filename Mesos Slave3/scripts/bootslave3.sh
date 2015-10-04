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
apt-get -y vim
apt-get install -y mesos

echo   
echo "**********************************************************************"
echo "*                                                                    *"
echo "* Configure Zookeeper                                                *"  
echo "*                                                                    *"  
echo "**********************************************************************" 
echo

# echo "zk://192.168.33.41:2181,192.168.33.42:2181/mesos" > /etc/mesos/zk
echo "zk://192.168.33.46:2181/mesos" > /etc/mesos/zk

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

echo "192.168.33.53" | tee /etc/mesos-slave/ip
cp /etc/mesos-slave/ip /etc/mesos-slave/hostname
echo 'docker,mesos' > /etc/mesos-slave/containerizers



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
# apt-get install -y python-pip
# pip install -U docker-compose
# docker-compose --version
# docker-compose --version

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