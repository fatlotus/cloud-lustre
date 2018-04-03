#!/bin/bash -ex
#
# Configures this node to have the Lustre kernel patches installed into the 
# kernel. This script is called by make-image.sh.

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

# Actually install Lustre.
sudo yum install -y kmod-lustre \
	kmod-lustre-osd-ldiskfs \
	lustre-osd-ldiskfs-mount \
	lustre \
	lustre-resource-agents \
	lustre-osd-zfs \
	zfs

echo lustre | sudo tee /etc/modules-load.d/lustre
echo ldiskfs | sudo tee -a /etc/modules-load.d/lustre

# Shut down the instance so that we can create a clean image.
sudo shutdown -h +1
