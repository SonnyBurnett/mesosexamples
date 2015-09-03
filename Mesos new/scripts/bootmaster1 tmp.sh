#!/usr/bin/env bash


echo   
echo "************************************************"
echo "*                                              *"
echo "*             install jre                      *"  
echo "*                                              *"  
echo "************************************************" 
echo
 
apt-get install openjdk-8-jre
JAVA_HOME=/usr/lib/jvm/java-7-openjdk-amd64/jre
export JAVA_HOME

echo   
echo "**********************************************************************"
echo "*                                                                    *"
echo "* Install the necessary components                                   *"  
echo "*                                                                    *"  
echo "**********************************************************************" 
echo

apt-get -y update
apt-get install -y autoconf libtool
apt-get -y install build-essential python-dev python-boto libcurl4-nss-dev libsasl2-dev maven libapr1-dev libsvn-dev
apt-get install -y vim

echo   
echo "**********************************************************************"
echo "*                                                                    *"
echo "* Configure Zookeeper                                                *"  
echo "*                                                                    *"  
echo "**********************************************************************" 
echo

mkdir -p /opt/zookeeper
cd /opt/zookeeper
cp /vagrant/puppet/modules/zookeeper/*.tar.gz .
tar xzf zookeeper-3.4.6.tar.gz
cd conf
echo "tickTime=2000" > zoo.cfg
echo "dataDir=/var/lib/zookeeper" >> zoo.cfg
echo "clientPort=2181" >> zoo.cfg
/opt/zookeeper/bin/zkServer.sh start


echo   
echo "**********************************************************************"
echo "*                                                                    *"
echo "* Configure Mesos                                                    *"  
echo "*                                                                    *"  
echo "**********************************************************************" 
echo

mkdir -p /opt/mesos
cd /opt/mesos
cp /vagrant/puppet/modules/mesos/*.tar.gz .
tar -zxf mesos-0.23.0.tar.gz
cd mesos
mkdir build
cd build
../configure
make

echo "1" > /etc/mesos-master/quorum
echo "192.168.33.45" | tee /etc/mesos-master/ip
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


ifconfig
exit 0