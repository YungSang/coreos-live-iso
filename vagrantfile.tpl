Vagrant.configure("2") do |config|
  # SSH in as the default 'core' user, it has the vagrant ssh key.
  config.ssh.username = "core"

  # Disable the base shared folder, Guest Additions are unavailable.
  config.vm.synced_folder ".", "/vagrant", disabled: true

  config.vm.provider :virtualbox do |vb|
    # Guest Additions are unavailable.
    vb.check_guest_additions = false

    # Fix docker not being able to resolve private registry in VirtualBox
    vb.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
    vb.customize ["modifyvm", :id, "--natdnsproxy1", "on"]
  end
end
