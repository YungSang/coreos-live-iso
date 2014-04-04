coreos.iso: Vagrantfile Dockerfile makeiso.sh
	vagrant up --no-provision
	vagrant provision

clean:
	vagrant destroy -f
	rm -f coreos.iso

.PHONY: clean
