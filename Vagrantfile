# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.box = "centos/7"
  config.vm.hostname = "redis.cluster.com"
  config.vm.network "private_network", ip: "192.168.33.10"
  # config.vm.synced_folder "./data", "/vagrant_data"
  config.vm.provider "virtualbox" do |vb|
    vb.name = "redisCluster"
    vb.memory = "1024"
    vb.cpus = 2
    vb.customize ["modifyvm", :id, "--audio", "none"]
  end
  config.vm.provision "shell", path: "bootstrap.sh"
end
