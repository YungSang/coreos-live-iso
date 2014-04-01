iso: coreos.iso

coreos.iso: Vagrantfile Dockerfile makeiso.sh oem/authorized_keys
	vagrant up --no-provision
	vagrant provision

oem/authorized_keys:
	curl -L https://raw.github.com/coreos/coreos-overlay/master/coreos-base/oem-vagrant/files/authorized_keys -o oem/authorized_keys

box: coreos.box

coreos.box: coreos.iso template.json vagrantfile.tpl tmp/insecure_private_key \
	oem/coreos-install oem/cloud-config.yml oem/override-plugin.rb
	packer build template.json

tmp/insecure_private_key:
	mkdir -p tmp
	curl -L https://raw.github.com/mitchellh/vagrant/master/keys/vagrant -o tmp/insecure_private_key

oem/coreos-install:
	curl -L https://raw.github.com/coreos/init/master/bin/coreos-install -o oem/coreos-install

clean:
	vagrant destroy -f
	rm -f coreos.iso
	rm -f coreos.box
	rm -f oem/authorized_keys oem/coreos-install
	rm -rf tmp/
	rm -rf output-*/

.PHONY: clean
