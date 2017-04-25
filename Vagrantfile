# -*- mode: ruby -*-
# vi: set ft=ruby :

VAGRANTFILE_API_VERSION = "2".freeze

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.box = "mvbcoding/awslinux"

  # Mount shared folder
  config.vm.synced_folder ".", "/vagrant/www"

  config.vm.network "private_network", ip: "192.168.100.100"
  config.vm.network "forwarded_port", guest: 80, host: 8080
  config.vm.network "forwarded_port", guest: 8000, host: 8000
  config.vm.network "forwarded_port", guest: 3306, host: 3306

  config.vm.provider :virtualbox do |vb|
    vb.customize ["modifyvm", :id, "--memory", 2048, "--cpus", 2, "--ioapic", "on"]
  end

  config.vm.provision :file, source: "vagrant/nginx/app.conf", destination: "app.conf"
  config.vm.provision :file, source: "vagrant/nginx/nginx.conf", destination: "nginx.conf"
  config.vm.provision :shell, path: "vagrant/bootstrap.sh"
  config.vm.provision :shell, path: "vagrant/bootstrap_vagrant.sh", privileged: false
end
