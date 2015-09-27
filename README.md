# mesosexamples
Examples for setting up a mesos cluster

Tools I personally use on my windows machine:

GitBash: https://git-scm.com/downloads 

Vagrant: http://www.vagrantup.com/downloads.html 

PuTTY: http://www.chiark.greenend.org.uk/~sgtatham/putty/download.html 

Virtual Box: https://www.virtualbox.org/wiki/Testbuilds

*********************************************************************

Try it the easy way:

Take the files in directory "stdbox". This examples uses vagrant boxes with Mesos pre-installed.

Change the vagrantfile to your personal liking (ip address, memory) and "vagrant up"

*********************************************************************

More extensive explanation:


To try a simple example with 1 Mesos Master and 3 Mesos Slaves:

Start Windows Explorer and go to a directory of your choice.

Right-click "Git Bash Here"

$ git clone https://github.com/SonnyBurnett/mesosexamples.git 

First start the Mesos Master:

In Windows Explorer Go to directory "Mesos new"

Right-click "Git Bash Here"

$ vagrant up

Now start the Mesos Slaves one by one by repeating this process

In directories "Mesos Slave 1", "Mesos Slave 2","Mesos Slave 3": vagrant up

Now go to your browser on the host (Windows in my case, I use Chrome)

type in: 192.168.33.46:5050 (if you haven't changed the ip address)

You should see the Mesos interface.

Type in: 192.168.33.46:8080

You should see the Marathon interface.

Start PuTTY

Log in to the Mesos Master:

192.168.33.46 (or any other ip address if you have changed this in the vagrantfile)

login/password: vagrant/vagrant

$ sudo docker ps

This should show that docker is running, but currently no containers run.

$ sudo docker pull jenkins

This will download a standard Jenkins container from Docker Hub.

$ sudo cd /vagrant/scripts

You might want to copy the json and bash script files to an other directory

$ ./startmesos.sh jenkins

This should start a jenkins container 

Go back to your browser on the host.

Type in: 192.168.33.46:8080

You should now see Jenkins running in a docker container

click on it

This will give you an url with the right port to access Jenkins.

Copy this in another tab in your browser and you should see the jenkins gui

Pretty cool he?

Now try a more advanced example with 3 masters and 3 slaves.