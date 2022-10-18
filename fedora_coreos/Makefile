ONESHELL:
SHELL = /bin/bash

common:
	butane -s -d files/ -p kore_common.bu > files/ignitions/kore_common.ign

libvirt: common
	ign=kore_libvirt.ign && \
	bu=kore_libvirt.bu && \
	butane -s -d files/ -p "$$bu" > "$$ign" && \
	./launch_fcos_libvirt.sh "$$ign"

production: common
	ign=kore_prod.ign \
	bu=kore_prod.bu \
	butane -s -d files/ -p "$$bu" > "$$ign" && \
	./launch_fcos_libvirt.sh "$$bu" "$$ign"