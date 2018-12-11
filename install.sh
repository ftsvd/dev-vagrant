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
# Purpose: base utils for every VM
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

	# Webmin - help for sysadmin
	wget http://prdownloads.sourceforge.net/webadmin/webmin-1.740-1.noarch.rpm
	sudo rpm -ivh webmin-*.rpm

	# fetch zip of custom config files
	wget https://github.com/sglanger/dev-vagrant/raw/master/files.zip
	unzip files.zip

	# update sshd.conf to enable passwd
	sudo mv /etc/ssh/sshd_config /etc/ssh/sshd_config.ori
	sudo cp files/sshd_config /etc/ssh/sshd_config
	sudo systemctl restart sshd
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

	# update the below files to enable remote postgres connections
	sudo mv /opt/PostgreSQL/9.2/data/pg_hba.conf /opt/PostgreSQL/9.2/data/pg_hba.conf.ori
	sudo mv /opt/PostgreSQL/9.2/data/postgresql.conf /opt/PostgreSQL/9.2/data/postgresql.conf.ori
    sudo cp files/postgres/postgresql.conf  /opt/PostgreSQL/9.2/data/
	sudo cp files/postgres/pg_hba.conf /opt/PostgreSQL/9.2/data/
	sudo systemctl restart 	postgresql-9.2
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



############################
# Main
# Purpose: execute cmmd line args
# 
# $1 command line arg for Case
#############################
	clear

	base
	#build
	#langs
	#dbase

	# GUI
	# first time wants a passwd
	#/usr/bin/vncserver 

