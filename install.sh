#!/bin/sh

################################################
# Author: SG Langer 12/11/2018
#
# Purpose: a scalable Vagrant build script for creating 
#	different kinds of VMs (Dev, dbase, webserver, Ansible provisioner, etc)
#
# good ref
# https://www.tecmint.com/things-to-do-after-minimal-rhel-centos-7-installation/
#
# NOte: people may ask why this and not a Makefile? Or why not a Makefile +
#	a provisioner like Puppet or ANsible? Becuase I can do
#  more in Bash then in Make, and going from  N frameworks to N - 1 (or 2) 
#  reduces the moving parts and external dependencies
##################################################


####################  base tools
####################  The parts below get installed on the base VM

base() {
######################################
# Purpose: base utils for every VM
#	
#
###################################
	echo "installing base utils"
	sudo yum install -y epel-release
	sudo yum install -y wget
	sudo yum install -y curl
	sudo yum install -y nmap
	sudo yum install -y nano
	sudo yum install -y unzip
	sudo yum install -y net-tools
	# need to Cron the below via "rkhunter --check"
	#sudo yum install -y rkhunter	

	# setup - rebuild it like it was under RHEL 6
	sudo yum install -y setuptool
	sudo yum install -y system-config-securitylevel-tui
	sudo yum install -y authconfig
	sudo yum install -y ntsysv
	sudo yum install -y NetworkManager-tui

	# fetch zip of custom config files
	wget https://github.com/sglanger/dev-vagrant/raw/master/files.zip
	unzip files.zip

	# update sshd.conf to enable passwd
	sudo mv /etc/ssh/sshd_config /etc/ssh/sshd_config.ori
	sudo cp /vagrant/files/sshd_config /etc/ssh/sshd_config
	sudo systemctl restart sshd

	# fix setup menu
	sudo mv /etc/setuptool.d/99system-config-network-tui /etc/setuptool.d/99system-config-network-tui.ori
	sudo cp /vagrant/files/99system-config-network-tui /etc/setuptool.d
}


################# build tools
#################

docker() {
######################################
# Purpose: for a Build VM, want tools to fetch
#	from git and be able to build Docker apps
#
###################################
	echo "installing build tools"
	sudo yum install -y git
	#sudo yum install -y docker
	# https://www.digitalocean.com/community/tutorials/how-to-install-and-use-docker-on-centos-7
	sudo curl -fsSL https://get.docker.com/ | sh

	sudo systemctl enable docker
	sudo systemctl start docker
}


vagrant() {
######################################
# Purpose: for a Build VM, want tools to fetch
#	from git and be able to build new VMs
#
###################################
	echo "installing build tools"
	sudo yum install -y git
	sudo wget https://download.virtualbox.org/virtualbox/rpm/rhel/7/x86_64/VirtualBox-5.2-5.2.8_121009_el7-1.x86_64.rpm
	sudo yum install -y VirtualBox-5.2-5.2.8_121009_el7-1.x86_64.rpm
	sudo wget https://releases.hashicorp.com/vagrant/2.2.2/vagrant_2.2.2_x86_64.rpm
	sudo yum install -y vagrant_2.2.2_x86_64.rpm

	# ansible config https://www.digitalocean.com/community/tutorials/how-to-install-and-configure-ansible-on-centos-7
	sudo yum install -y ansible
}


#################### databases
####################

postgres() {
######################################
# Purpose: install, create and start
#	default postgres
#
# https://www.digitalocean.com/community/tutorials/how-to-install-and-use-postgresql-on-cento
###################################

	echo "installing postgres"
	sudo yum install -y postgresql-server postgresql-contrib
	sudo postgresql-setup initdb
	#sudo systemctl start postgresql 
	sudo systemctl enable postgresql

	# update the below files to enable remote postgres connections
	sudo mv /var/lib/pgsql/data/pg_hba.conf /var/lib/pgsql/data/pg_hba.conf.ori
	sudo mv /var/lib/pgsql/data/postgresql.conf /var/lib/pgsql/data/postgresql.conf.ori
	sudo cp /vagrant/files/postgres/postgresql.conf  /var/lib/pgsql/data/
	sudo cp /vagrant/files/postgres/pg_hba.conf /var/lib/pgsql/data/
	sudo systemctl start 	postgresql

	# and setup detault user
	#sudo createuser 
}


################################### dev tools
###################################

dev() {
######################################
# Purpose: for a development VM want some 
#		languages and maybe IDE's
#
###################################
	echo "installing languages"

	# java, c, python,  and eclipse
	sudo yum install -y java-1.8.0-openjdk
	sudo yum install -y java-1.8.0-openjdk-devel
	sudo yum install -y centos-release-scl
	sudo yum install -y devtoolset-4
	sudo yum install -y python python-lxml python-devel
	
	# gradle https://www.vultr.com/docs/how-to-install-gradle-on-centos-7
	wget https://services.gradle.org/distributions/gradle-3.4.1-bin.zip
	sudo mkdir /opt/gradle
	sudo unzip -d /opt/gradle gradle-3.4.1-bin.zip
	sudo PATH=$PATH:/opt/gradle/gradle-3.4.1/bin
}



##############################  GUI and/or IDEs
##############################


GUI() {
######################################
# Purpose: VNC running via X, then xRDP on VNC
#
#	in-progress
#
###################################
	echo "installing GUI"
	# https://www.centos.org/forums/viewtopic.php?t=52900
	sudo yum groupinstall "GNOME Desktop"
	sudo yum install -y tigervnc-server
	sudo wget http://dl.fedoraproject.org/pub/epel/testing/6/x86_64/Packages/x/xrdp-0.6.1-5.el6.x86_64.rpm
	sudo yum install -y xrdp-0.6.1-5.el6.x86_64.rpm
	sudo service xrdp start
	sudo /sbin/chkconfig xrdp on
	sudo /sbin/chkconfig vncserver on
}


####################### Top level appliance DOckers here down
####################### These, if installed, are pulled from DOckerhub and extend the
####################### base VM w/out altering it

mirth_hl7() {
############################
# Purpose:
#
#
##########################

	# we are assuming postgres, docker have already been called
	postgres
	docker
	
	# To make a persistent mirth dbase with postgres, first make a stub dbase 
	sudo /usr/bin/createdb -U postgres mirth
	sudo /usr/bin/psql -U postgres -d mirth < /vagrant/files/mirth/mirthdb.sql
	
	# and now get mirth DOcker
	sudo docker pull brandonstevens/mirth-connect

	# and start it
	sudo docker run --name mirth-hl7  -p 8080:8080 -p 8443:8443 --rm brandonstevens/mirth-connect
}


orthanc() {
############################
# Purpose: lay down the dependencies 
#	Orthanc needs to run and then
#	install Sebastian's Orthanc DOcker
##############################

	#postgres
	#docker

	# To make a persistent Orthanc dbase with postgres, first make a stub dbase 
	sudo /usr/bin/createdb -U postgres orthanc
	sudo /usr/bin/psql -U postgres -d orthanc < /vagrant/files/orthanc/orthanc.sql
	
	# https://book.orthanc-server.com/users/docker.html
	sudo docker pull jodogne/orthanc-plugins
	
	# this runs Orthanc on SQLlite which goes poof when DOcker shuts down
	#sudo docker run  --name orthanc -p 4242:4242 -p 8042:8042 --rm jodogne/orthanc-plugins 

	# this starts Orthanc with a new conf file that point to Postgres
	# but the Permissions are wrong and orthanc cannot read it
	# orthanc.json must be root/root
    sudo docker run --name orthanc -p 4242:4242 -p 8042:8042 --rm -v /vagrant/files/orthanc/orthanc.json:/etc/orthanc/orthanc.json:ro jodogne/orthanc-plugins 
}


############################
# Main
# Purpose: provisioner
# Caller: parent Vagrantfile
#
# 
#############################
	clear
	# base is always called
	base

	# then depending on role we call one or more others
	mirth_hl7
	orthanc

	# GUI
	# first time wants a passwd
	#/usr/bin/vncserver 
	
	exit
	

