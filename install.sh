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
##################################################


base() {
######################################
# Purpose: 
#	
#
###################################

	echo "installing base utils"
	sudo yum install -y epel-release
	sudo yum install -y wget
	sudo yum install -y nmap
	sudo yum install -y nano
	sudo yum install -y unzip
	# need to Cron the below via "rkhunter --check"
	sudo yum install -y rkhunter	

	wget http://prdownloads.sourceforge.net/webadmin/webmin-1.740-1.noarch.rpm
	sudo rpm -ivh webmin-*.rpm
}

build() {
######################################
# Purpose: for a Dev VM, want tools to fetch
#	from git and be able to build new VMs
#
###################################
	echo "installing build tools"
	sudo yum install -y git
	sudo yum install -y docker
	sudo wget https://download.virtualbox.org/virtualbox/rpm/rhel/7/x86_64/VirtualBox-5.2-5.2.8_121009_el7-1.x86_64.rpm
	sudo yum install -y VirtualBox-5.2-5.2.8_121009_el7-1.x86_64.rpm
	sudo wget https://releases.hashicorp.com/vagrant/2.2.2/vagrant_2.2.2_x86_64.rpm
	sudo yum install -y vagrant_2.2.2_x86_64.rpm

	# ansible config https://www.digitalocean.com/community/tutorials/how-to-install-and-configure-ansible-on-centos-7
	sudo yum install -y ansible
}


dbase() {
######################################
# Purpose: install, create and start
#	default postgres
#
# https://www.digitalocean.com/community/tutorials/how-to-install-and-use-postgresql-on-centos-7
###################################

	echo "installing postgres"
	sudo yum install -y postgresql-server postgresql-contrib
	sudo postgresql-setup initdb
	sudo systemctl start postgresql 
	sudo systemctl enable postgresql
}


langs() {
######################################
# Purpose: 
#	
#
###################################
	echo "installing langauges"

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


GUI() {
######################################
# Purpose: 
#	in- progress
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



############################
# Main
# Purpose: execute cmmd line args
# 
# $1 command line arg for Case
#############################
	clear

	base
	build
	langs
	#dbase

	# GUI
	# first time wants a passwd
	#/usr/bin/vncserver 

