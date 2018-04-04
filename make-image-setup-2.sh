#!/bin/bash -ex
#
# Configures this node to have the Lustre kernel patches installed into the 
# kernel. This script is called by make-image.sh.

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
echo zfs | sudo tee -a /etc/modules-load.d/lustre

# Shut down the instance so that we can create a clean image.
sudo shutdown -h +1
