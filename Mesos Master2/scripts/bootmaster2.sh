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
echo "2" > /etc/zookeeper/conf/myid
echo "server.1=192.168.33.41:2888:3888" >> /etc/zookeeper/conf/zoo.cfg
echo "server.2=192.168.33.42:2888:3888" >> /etc/zookeeper/conf/zoo.cfg

echo   
echo "**********************************************************************"
echo "*                                                                    *"
echo "* Configure Mesos                                                    *"  
echo "*                                                                    *"  
echo "**********************************************************************" 
echo

echo "1" > /etc/mesos-master/quorum
echo "192.168.33.42" | tee /etc/mesos-master/ip
cp /etc/mesos-master/ip /etc/mesos-master/hostname

echo   
echo "**********************************************************************"
echo "*                                                                    *"
echo "* Configure Marathon                                                 *"  
echo "*                                                                    *"  
echo "**********************************************************************" 
echo

mkdir -p /etc/marathon/conf
echo "192.168.33.42" > /etc/marathon/conf/hostname
echo "zk://192.168.33.42:2181/mesos" > /etc/marathon/conf/master
echo "zk://192.168.33.42:2181/marathon" > /etc/marathon/conf/zk

echo   
echo "**********************************************************************"
echo "*                                                                    *"
echo "* (re)start services                                                 *"  
echo "*                                                                    *"  
echo "**********************************************************************" 
echo

# stop mesos-slave
# echo manual | tee /etc/init/mesos-slave.override

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

echo "192.168.33.42" | tee /etc/mesos-slave/ip
cp /etc/mesos-slave/ip /etc/mesos-slave/hostname

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
echo "* Install & configure docker                                         *"  
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

docker pull jenkins

ifconfig
exit 0