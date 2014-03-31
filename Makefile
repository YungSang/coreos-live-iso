coreos.iso: Vagrantfile Dockerfile makeiso.sh oem/authorized_keys
	vagrant up --no-provision
	vagrant provision

oem/authorized_keys:
	mkdir -p oem
	curl -L https://raw.github.com/coreos/coreos-overlay/master/coreos-base/oem-vagrant/files/authorized_keys -o oem/authorized_keys

clean:
	vagrant destroy -f
	rm -f coreos.iso
	rm -rf oem/

.PHONY: clean
