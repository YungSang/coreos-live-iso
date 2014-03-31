# -*- mode: ruby -*-
# vi: set ft=ruby :

VAGRANTFILE_API_VERSION = "2"

Vagrant.require_version ">= 1.5.0"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.box = "yungsang/boot2docker"

  config.vm.network :private_network, ip: "192.168.33.10"

  config.vm.synced_folder ".", "/vagrant", type: "nfs"

  # Adjust datetime after suspend and resume
  config.vm.provision :shell do |s|
    s.inline = <<-EOT
      sudo /usr/local/bin/ntpclient -s -h pool.ntp.org
      date
    EOT
  end

  config.vm.provision :docker do |d|
    d.build_image "/vagrant", args: "-t yungsang/coreos-live-iso"
  end

  config.vm.provision :shell do |s|
    s.inline = <<-EOT
      sudo docker rm build-coreos-live-iso || true
    EOT
  end

  config.vm.provision :docker do |d|
    d.run "build-coreos-live-iso",
      image: "yungsang/coreos-live-iso",
      args: "--privileged"
  end

  config.vm.provision :shell do |s|
    s.inline = <<-EOT
      # Wait to make iso
      sudo docker wait build-coreos-live-iso
      sudo docker cp build-coreos-live-iso:/coreos.iso /vagrant
    EOT
  end
end
