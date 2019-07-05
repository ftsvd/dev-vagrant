# -*- mode: ruby -*-
# vi: set ft=ruby :

# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.

Vagrant.configure("2") do |config|
 
  # sgl adds, see
  # https://cloud.centos.org/centos/7/vagrant/x86_64/images/
  config.vm.box = "dev-vagrant"
  #config.vm.box_url = "https://github.com/2creatives/vagrant-centos/releases/download/v6.5.3/centos65-x86_64-20140116.box"
  config.vm.box_url = "https://cloud.centos.org/centos/7/vagrant/x86_64/images/CentOS-7-x86_64-Vagrant-1809_01.VirtualBox.box"

  # Port forwarding - uncomment the items below you will actually use
  # (as dictated by what is selected to install in the install.sh )
  # ssh port - not needed,  Vagrant does by default

  # host ip = 10.0.2.2
  # first guest ip = 10.0.2.15
  # for orthanc
  config.vm.network "forwarded_port", guest: 8042, host: 8042
  config.vm.network "forwarded_port", guest: 4242, host: 4242

  # for VM postgres
  # https://github.com/jackdb/pg-app-dev-vm/tree/master/Vagrant-setup
  # https://wiki.postgresql.org/wiki/PostgreSQL_For_Development_With_Vagrant#Linux_Installation
  #config.vm.network "forwarded_port", guest: 5432, host: 5433, guest_ip: "10.0.2.15", host_ip: "127.0.0.1", protocol: "tcp"
  #config.vm.network "forwarded_port", guest: 5432, host: 5433, guest_ip: "10.0.2.15", host_ip: "10.0.2.2", protocol: "udp"
  config.vm.network "forwarded_port", guest: 5432, host: 5433, protocol: "tcp"
  config.vm.network "forwarded_port", guest: 5432, host: 5433, protocol: "udp"
  
  # for MIRTH HL7
 
  #for RDP session -
  #config.vm.network "forwarded_port", guest: 3389, host: 2179
  #config.vm.provider :virtualbox do |vb|
  #	vb.gui = true
  #end

  config.vm.provider "vmware" do |vb|

  end

  
  # Enable provisioning with a shell script. Additional provisioners such as
  # Puppet, Chef, Ansible, Salt, and Docker are also available. Please see the
  # documentation for more information about their specific syntax and use.
  # config.vm.provision "shell", inline: <<-SHELL
  #   apt-get update
  #   apt-get install -y apache2
  # SHELL
  config.vm.provision "shell", path: "install.sh"

end
