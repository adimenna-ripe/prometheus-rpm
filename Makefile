SHELL := bash

MANUAL = prometheus2 \
ping_exporter \
mtail \

AUTO_GENERATED = alertmanager \
node_exporter \
blackbox_exporter \
snmp_exporter \
pushgateway \
mysqld_exporter \
postgres_exporter \
redis_exporter \
kafka_exporter \
nginx_exporter \
bind_exporter \
json_exporter \
keepalived_exporter \
statsd_exporter \
collectd_exporter \
memcached_exporter \
smokeping_prober \
iperf3_exporter \
apache_exporter \
exporter_exporter \
junos_exporter \
process_exporter \
ssl_exporter \
karma \
phpfpm_exporter \
sql_exporter \
cadvisor \
dellhw_exporter \
exim_exporter \
systemd_exporter

.PHONY: $(MANUAL) $(AUTO_GENERATED)

INTERACTIVE:=$(shell [ -t 0 ] && echo 1)
ifdef INTERACTIVE
	DOCKER_FLAGS = -it --rm
else
	DOCKER_FLAGS = --rm
endif

all: auto manual

manual: $(MANUAL)
auto: $(AUTO_GENERATED)

manual9: $(addprefix build9-,$(MANUAL))
manual8: $(addprefix build8-,$(MANUAL))
manual7: $(addprefix build7-,$(MANUAL))

$(addprefix build9-,$(MANUAL)):
	$(eval PACKAGE=$(subst build9-,,$@))
	[ -d ${PWD}/_dist9 ] || mkdir ${PWD}/_dist9 
	[ -d ${PWD}/_cache_dnf ] || mkdir ${PWD}/_cache_dnf 
	docker run ${DOCKER_FLAGS} \
		-v ${PWD}/${PACKAGE}:/rpmbuild/SOURCES \
		-v ${PWD}/_dist9:/rpmbuild/RPMS/x86_64 \
		-v ${PWD}/_dist9:/rpmbuild/RPMS/noarch \
		-v ${PWD}/_cache_dnf:/var/cache/dnf \
		ghcr.io/adimenna-ripe/oracle9-rpm-builder:main \
		build-spec SOURCES/${PACKAGE}.spec
	# Test the install
	[ -d ${PWD}/_dist9 ] || mkdir ${PWD}/_dist9      
	[ -d ${PWD}/_cache_dnf ] || mkdir ${PWD}/_cache_dnf
	docker run --privileged ${DOCKER_FLAGS} \
		-v ${PWD}/_dist9:/var/tmp/ \
		-v ${PWD}/_cache_dnf:/var/cache/dnf \
		ghcr.io/adimenna-ripe/oracle9-rpm-builder:main \
		/bin/bash -c '/usr/bin/dnf install --verbose -y /var/tmp/${PACKAGE}*.rpm'

$(addprefix build8-,$(MANUAL)):
	$(eval PACKAGE=$(subst build8-,,$@))
	[ -d ${PWD}/_dist8 ] || mkdir ${PWD}/_dist8 
	[ -d ${PWD}/_cache_dnf ] || mkdir ${PWD}/_cache_dnf 
	docker run ${DOCKER_FLAGS} \
		-v ${PWD}/${PACKAGE}:/rpmbuild/SOURCES \
		-v ${PWD}/_dist8:/rpmbuild/RPMS/x86_64 \
		-v ${PWD}/_dist8:/rpmbuild/RPMS/noarch \
		-v ${PWD}/_cache_dnf:/var/cache/dnf \
		ghcr.io/adimenna-ripe/oracle8-rpm-builder:main \
		build-spec SOURCES/${PACKAGE}.spec
	# Test the install
	[ -d ${PWD}/_dist8 ] || mkdir ${PWD}/_dist8      
	[ -d ${PWD}/_cache_dnf ] || mkdir ${PWD}/_cache_dnf
	docker run --privileged ${DOCKER_FLAGS} \
		-v ${PWD}/_dist8:/var/tmp/ \
		-v ${PWD}/_cache_dnf:/var/cache/dnf \
		ghcr.io/adimenna-ripe/oracle8-rpm-builder:main \
		/bin/bash -c '/usr/bin/dnf install --verbose -y /var/tmp/${PACKAGE}*.rpm'

$(addprefix build7-,$(MANUAL)):
	$(eval PACKAGE=$(subst build7-,,$@))
	[ -d ${PWD}/_dist7 ] || mkdir ${PWD}/_dist7      
	[ -d ${PWD}/_cache_yum ] || mkdir ${PWD}/_cache_yum
	docker run ${DOCKER_FLAGS} \
		-v ${PWD}/${PACKAGE}:/rpmbuild/SOURCES \
		-v ${PWD}/_dist7:/rpmbuild/RPMS/x86_64 \
		-v ${PWD}/_dist7:/rpmbuild/RPMS/noarch \
		-v ${PWD}/_cache_yum:/var/cache/yum \
		ghcr.io/adimenna-ripe/centos7-rpm-builder:main \
		build-spec SOURCES/${PACKAGE}.spec
	# Test the install
	[ -d ${PWD}/_dist7 ] || mkdir ${PWD}/_dist7      
	[ -d ${PWD}/_cache_yum ] || mkdir ${PWD}/_cache_yum
	docker run --privileged ${DOCKER_FLAGS} \
		-v ${PWD}/_dist7:/var/tmp/ \
		-v ${PWD}/_cache_yum:/var/cache/yum \
		ghcr.io/adimenna-ripe/centos7-rpm-builder:main \
		/bin/bash -c '/usr/bin/yum install --verbose -y /var/tmp/${PACKAGE}*.rpm'


auto9: $(addprefix build9-,$(AUTO_GENERATED))
auto8: $(addprefix build8-,$(AUTO_GENERATED))
auto7: $(addprefix build7-,$(AUTO_GENERATED))

$(addprefix build9-,$(AUTO_GENERATED)):
	$(eval PACKAGE=$(subst build9-,,$@))

	python3 ./generate.py --templates ${PACKAGE}
	[ -d ${PWD}/_dist9 ] || mkdir ${PWD}/_dist9      
	[ -d ${PWD}/_cache_dnf ] || mkdir ${PWD}/_cache_dnf
	docker run ${DOCKER_FLAGS} \
		-v ${PWD}/${PACKAGE}:/rpmbuild/SOURCES \
		-v ${PWD}/_dist9:/rpmbuild/RPMS/x86_64 \
		-v ${PWD}/_dist9:/rpmbuild/RPMS/noarch \
		-v ${PWD}/_cache_dnf:/var/cache/dnf \
		ghcr.io/adimenna-ripe/oracle9-rpm-builder:main \
		build-spec SOURCES/autogen_${PACKAGE}.spec
	# Test the install
	[ -d ${PWD}/_dist9 ] || mkdir ${PWD}/_dist9      
	[ -d ${PWD}/_cache_dnf ] || mkdir ${PWD}/_cache_dnf
	docker run --privileged ${DOCKER_FLAGS} \
		-v ${PWD}/_dist9:/var/tmp/ \
		-v ${PWD}/_cache_dnf:/var/cache/dnf \
		ghcr.io/adimenna-ripe/oracle9-rpm-builder:main \
		/bin/bash -c '/usr/bin/dnf install --verbose -y /var/tmp/${PACKAGE}*.rpm'

sign9:
	docker run --rm \
		-v ${PWD}/_dist9:/rpmbuild/RPMS/x86_64 \
		-v ${PWD}/bin:/rpmbuild/bin \
		-v ${PWD}/RPM-GPG-KEY-prometheus-rpm:/rpmbuild/RPM-GPG-KEY-prometheus-rpm \
		-v ${PWD}/secret.asc:/rpmbuild/secret.asc \
		-v ${PWD}/.passphrase:/rpmbuild/.passphrase \
		ghcr.io/adimenna-ripe/oracle9-rpm-builder:main \
		bin/sign

$(addprefix build8-,$(AUTO_GENERATED)):
	$(eval PACKAGE=$(subst build8-,,$@))

	python3 ./generate.py --templates ${PACKAGE}
	[ -d ${PWD}/_dist8 ] || mkdir ${PWD}/_dist8      
	[ -d ${PWD}/_cache_dnf ] || mkdir ${PWD}/_cache_dnf
	docker run ${DOCKER_FLAGS} \
		-v ${PWD}/${PACKAGE}:/rpmbuild/SOURCES \
		-v ${PWD}/_dist8:/rpmbuild/RPMS/x86_64 \
		-v ${PWD}/_dist8:/rpmbuild/RPMS/noarch \
		-v ${PWD}/_cache_dnf:/var/cache/dnf \
		ghcr.io/adimenna-ripe/oracle8-rpm-builder:main \
		build-spec SOURCES/autogen_${PACKAGE}.spec
	# Test the install
	[ -d ${PWD}/_dist8 ] || mkdir ${PWD}/_dist8      
	[ -d ${PWD}/_cache_dnf ] || mkdir ${PWD}/_cache_dnf
	docker run --privileged ${DOCKER_FLAGS} \
		-v ${PWD}/_dist8:/var/tmp/ \
		-v ${PWD}/_cache_dnf:/var/cache/dnf \
		ghcr.io/adimenna-ripe/oracle8-rpm-builder:main \
		/bin/bash -c '/usr/bin/dnf install --verbose -y /var/tmp/${PACKAGE}*.rpm'

sign8:
	docker run --rm \
		-v ${PWD}/_dist8:/rpmbuild/RPMS/x86_64 \
		-v ${PWD}/bin:/rpmbuild/bin \
		-v ${PWD}/RPM-GPG-KEY-prometheus-rpm:/rpmbuild/RPM-GPG-KEY-prometheus-rpm \
		-v ${PWD}/secret.asc:/rpmbuild/secret.asc \
		-v ${PWD}/.passphrase:/rpmbuild/.passphrase \
		ghcr.io/adimenna-ripe/oracle8-rpm-builder:main \
		bin/sign

$(addprefix build7-,$(AUTO_GENERATED)):
	$(eval PACKAGE=$(subst build7-,,$@))

	python3 ./generate.py --templates ${PACKAGE}
	[ -d ${PWD}/_dist7 ] || mkdir ${PWD}/_dist7
	[ -d ${PWD}/_cache_yum ] || mkdir ${PWD}/_cache_yum
	docker run ${DOCKER_FLAGS} \
		-v ${PWD}/${PACKAGE}:/rpmbuild/SOURCES \
		-v ${PWD}/_dist7:/rpmbuild/RPMS/x86_64 \
		-v ${PWD}/_dist7:/rpmbuild/RPMS/noarch \
		-v ${PWD}/_cache_yum:/var/cache/yum \
		ghcr.io/adimenna-ripe/centos7-rpm-builder:main \
		build-spec SOURCES/autogen_${PACKAGE}.spec
	# Test the install
	[ -d ${PWD}/_dist7 ] || mkdir ${PWD}/_dist7
	[ -d ${PWD}/_cache_yum ] || mkdir ${PWD}/_cache_yum
	docker run --privileged ${DOCKER_FLAGS} \
		-v ${PWD}/_dist7:/var/tmp/ \
		-v ${PWD}/_cache_yum:/var/cache/yum \
		ghcr.io/adimenna-ripe/centos7-rpm-builder:main \
		/bin/bash -c '/usr/bin/yum install --verbose -y /var/tmp/${PACKAGE}*.rpm'

sign7:
	docker run --rm \
		-v ${PWD}/_dist7:/rpmbuild/RPMS/x86_64 \
		-v ${PWD}/bin:/rpmbuild/bin \
		-v ${PWD}/RPM-GPG-KEY-prometheus-rpm:/rpmbuild/RPM-GPG-KEY-prometheus-rpm \
		-v ${PWD}/secret.asc:/rpmbuild/secret.asc \
		-v ${PWD}/.passphrase:/rpmbuild/.passphrase \
		ghcr.io/adimenna-ripe/centos7-rpm-builder:main \
		bin/sign

$(foreach \
	PACKAGE,$(MANUAL),$(eval \
		${PACKAGE}: \
			$(addprefix build9-,${PACKAGE}) \
			$(addprefix build8-,${PACKAGE}) \
			$(addprefix build7-,${PACKAGE}) \
	) \
)

$(foreach \
	PACKAGE,$(AUTO_GENERATED),$(eval \
		${PACKAGE}: \
			$(addprefix build9-,${PACKAGE}) \
			$(addprefix build8-,${PACKAGE}) \
			$(addprefix build7-,${PACKAGE}) \
	) \
)

sign: sign9 sign8 sign7

publish9: sign9
	for package in $$(ls _dist9/*.rpm); do\
	    cloudsmith push rpm adimenna-ripe/prometheus-rpm/el/9 $$package -k ${CLOUDSMITH_TOKEN};\
	done

publish8: sign8
	for package in $$(ls _dist8/*.rpm); do\
	    cloudsmith push rpm adimenna-ripe/prometheus-rpm/el/8 $$package -k ${CLOUDSMITH_TOKEN};\
	done

publish7: sign7
	package_cloud push --skip-errors prometheus-rpm/release/el/7 _dist7/*.rpm

publish: publish9 publish8 publish7

clean:
	rm -rf _cache_dnf _cache_yum _dist*
	rm -f **/*.tar.gz
	rm -f **/*.jar
	rm -f **/autogen_*{default,init,unit,spec}
