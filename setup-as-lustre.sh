#!/bin/bash -ex

ZONE=us-central1-f
INSTANCE=build-lustre-image
FAMILY=centos-7-lustre

if ! [[ -f /.lustre-phase1 ]]; then
	# Configure the kernerl to have the latest lustre MPMs.

	# Set up this instance to install the latest Lustre RPMs.
	sudo tee /etc/yum.repos.d/lustre-cloud.repo >/dev/null <<EOF
[lustre-server]
name=lustre-server
baseurl=https://downloads.hpdd.intel.com/public/lustre/latest-release/el7/server
# exclude=*debuginfo*
gpgcheck=0

[lustre-client]
name=lustre-client
baseurl=https://downloads.hpdd.intel.com/public/lustre/latest-release/el7/client
# exclude=*debuginfo*
gpgcheck=0

[e2fsprogs-wc]
name=e2fsprogs-wc
baseurl=https://downloads.hpdd.intel.com/public/e2fsprogs/latest/el7
# exclude=*debuginfo*
gpgcheck=0
EOF
	
	# Pull down the latest versions of everything.
	sudo yum update -y
	
	# Reinstall the kernel, possibly to an older version.
	for step in downgrade install; do
		sudo yum -y --nogpgcheck --disablerepo=base,extras,updates \
			--enablerepo=lustre-server "${step}" \
			kernel \
			kernel-devel \
			kernel-headers \
			kernel-tools \
			kernel-tools-libs \
			kernel-tools-libs-devel
	done

	# Proceed to the next phase of the build.
	sudo touch /.lustre-phase1
	sudo shutdown -r now

elif ! [[ -f /.lustre-phase2 ]]; then

	# Install lustre and ZFS.
	sudo yum install -y kmod-lustre \
		kmod-lustre-osd-ldiskfs \
		lustre-osd-ldiskfs-mount \
		lustre \
		lustre-resource-agents \
		lustre-osd-zfs \
		zfs
	
	echo lustre | sudo tee /etc/modules-load.d/lustre
	echo ldiskfs | sudo tee -a /etc/modules-load.d/lustre
	echo zfs | sudo tee -a /etc/modules-load.d/lustre

	sudo touch /.lustre-phase2

	IMAGE="${FAMILY}-$(date +%s)"

	gcloud compute images create \
		--source-disk $INSTANCE \
		--source-disk-zone $ZONE \
		--family $FAMILY \
		--force \
		$IMAGE

	gcloud compute images list \
		--filter='family: centos-7-lustre' \
		--format='value(name)' | \
		grep -v $IMAGE | \
		xargs -I{} gcloud compute images delete {}

	echo lustre-setup-success

	gcloud compute instances delete -q --zone=$ZONE $INSTANCE
fi
