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
  # ssh port
  #config.vm.network "forwarded_port", guest: 22, host: 2222

  #for RDP session -
  #config.vm.network "forwarded_port", guest: 3389, host: 2179
  #config.vm.provider :virtualbox do |vb|
  #	vb.gui = true
  #end

  # for postgres
  config.vm.network "forwarded_port", guest: 5432, host: 5433

  # for Webmin
  #config.vm.network "forwarded_port", guest: 10000, host: 10000

  # Enable provisioning with a shell script. Additional provisioners such as
  # Puppet, Chef, Ansible, Salt, and Docker are also available. Please see the
  # documentation for more information about their specific syntax and use.
  # config.vm.provision "shell", inline: <<-SHELL
  #   apt-get update
  #   apt-get install -y apache2
  # SHELL
  config.vm.provision "shell", path: "install.sh"

end
